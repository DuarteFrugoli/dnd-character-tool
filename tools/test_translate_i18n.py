"""Offline tests for SRD overlay extraction and incremental translation."""

import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from urllib.error import HTTPError, URLError

import translate_i18n as translation
from check_srd_i18n import missing_paths


class TranslationToolTests(unittest.TestCase):
    def test_turkish_is_available_for_all_pack_operations(self):
        self.assertEqual(translation.LOCALE_LANG["tr"], "tr")

    def test_2024_extractors_only_emit_localizable_fields(self):
        with patch.object(translation, "SRD_DIR", translation.ROOT / "assets/data/srd/5.2.1"):
            for filename, extractor in translation.EXTRACTORS.items():
                with self.subTest(filename=filename):
                    self.assertTrue(extractor())
            background = translation.extract_backgrounds()["Acolyte"]
            self.assertEqual(background, {"name": "Acolyte"})
            barbarian = translation.extract_classes()["Barbarian"]
            self.assertNotIn("progression", barbarian)
            self.assertNotIn("weaponProficiencies", barbarian)
            feat = translation.extract_feats()["Alert"]
            self.assertNotIn("prerequisite", feat)
            equipment = translation.extract_equipment()
            self.assertEqual(len(equipment["weaponMasteries"]), 8)
            spell = translation.extract_spells()["Acid Splash"]
            self.assertIn("castingTime", spell)
            self.assertIn("range", spell)
            self.assertIn("duration", spell)

    def test_merge_keeps_manual_2014_magic_item_translation(self):
        source = translation.ROOT / "assets/data/srd/5.1"
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "magic_items.json"
            destination.write_text(
                json.dumps({"Potion of Healing": {
                    "name": "Manual name", "description": "Manual description",
                }}), encoding="utf-8",
            )
            with patch.object(translation, "SRD_DIR", source), patch.object(
                translation, "_translate", side_effect=lambda text, _: f"Translated: {text}"
            ):
                translation.translate_file("magic_items.json", destination, "pt", merge=True)
            result = json.loads(destination.read_text(encoding="utf-8"))
            self.assertEqual(
                len(result), len(json.loads((source / "magic_items.json").read_text(encoding="utf-8")))
            )
            self.assertEqual(result["Potion of Healing"]["name"], "Manual name")
            self.assertEqual(result["Potion of Healing"]["description"], "Manual description")

    def test_interrupted_translation_can_resume_without_overwriting(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "demo.json"
            extractor = lambda: {
                "first": {"name": "First"},
                "second": {"name": "Second"},
            }
            with patch.dict(translation.EXTRACTORS, {"demo.json": extractor}):
                with patch.object(translation, "_translate", side_effect=["Primeiro", RuntimeError("offline")]):
                    with self.assertRaisesRegex(RuntimeError, "offline"):
                        translation.translate_file("demo.json", destination, "pt", merge=True)
                self.assertEqual(json.loads(destination.read_text(encoding="utf-8")), {
                    "first": {"name": "Primeiro"},
                })
                with patch.object(translation, "_translate", return_value="Segundo") as translate:
                    translation.translate_file("demo.json", destination, "pt", merge=True)
                translate.assert_called_once_with("Second", "pt")
                self.assertEqual(json.loads(destination.read_text(encoding="utf-8")), {
                    "first": {"name": "Primeiro"},
                    "second": {"name": "Segundo"},
                })

    def test_force_failure_does_not_replace_existing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "demo.json"
            destination.write_text('{"manual":{"name":"Reviewed"}}', encoding="utf-8")
            with patch.dict(translation.EXTRACTORS, {"demo.json": lambda: {
                "first": {"name": "First"}, "second": {"name": "Second"},
            }}), patch.object(
                translation, "_translate", side_effect=["Primeiro", RuntimeError("offline")]
            ):
                with self.assertRaisesRegex(RuntimeError, "offline"):
                    translation.translate_file("demo.json", destination, "pt")
            self.assertEqual(json.loads(destination.read_text(encoding="utf-8")), {
                "manual": {"name": "Reviewed"},
            })

    def test_nested_choice_sources_are_checkpointed_independently(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "feature_choices.json"
            extractor = lambda: {"optionSources": {
                "first": {"name": "First"},
                "second": {"name": "Second"},
            }}
            with patch.dict(translation.EXTRACTORS, {"feature_choices.json": extractor}):
                with patch.object(translation, "_translate", side_effect=["Primeiro", RuntimeError("offline")]):
                    with self.assertRaisesRegex(RuntimeError, "offline"):
                        translation.translate_file("feature_choices.json", destination, "pt", merge=True)
                self.assertEqual(json.loads(destination.read_text(encoding="utf-8")), {
                    "optionSources": {"first": {"name": "Primeiro"}},
                })
                with patch.object(translation, "_translate", return_value="Segundo") as translate:
                    translation.translate_file("feature_choices.json", destination, "pt", merge=True)
                translate.assert_called_once_with("Second", "pt")

    def test_long_text_is_split_under_translation_limit(self):
        chunks = translation._translation_chunks("A long sentence. " * 500)
        self.assertGreater(len(chunks), 1)
        self.assertTrue(all(len(chunk) <= 4500 for chunk in chunks))

    def test_coverage_check_reports_only_missing_text(self):
        source = {"item": {"name": "Sword", "description": "A blade"}}
        overlay = {"item": {"name": "Espada"}}
        self.assertEqual(list(missing_paths(source, overlay)), [("item", "description")])

    def test_technical_fields_are_not_translated_or_counted(self):
        source = {"choice": {
            "id": "arcane_choice", "type": "spell", "formula": "2 + level",
            "name": "Arcane Choice",
        }}
        with patch.object(translation, "_translate", return_value="Escolha Arcana") as translate:
            result = translation._merge_translations(source, None, "pt")
        self.assertEqual(result["choice"]["id"], "arcane_choice")
        self.assertEqual(result["choice"]["type"], "spell")
        self.assertEqual(result["choice"]["formula"], "2 + level")
        self.assertEqual(result["choice"]["name"], "Escolha Arcana")
        translate.assert_called_once_with("Arcane Choice", "pt")
        self.assertEqual(translation._missing_text_count(source, {}), 1)
        self.assertEqual(list(translation._missing_text_values(source, {})), ["Arcane Choice"])
        self.assertEqual(list(missing_paths(source, {})), [("choice", "name")])

    def test_rate_limit_stops_without_repeating_blocked_requests(self):
        class BlockedTranslator:
            def __init__(self, **kwargs):
                pass

            def translate(self, text):
                raise translation.TooManyRequests()

        with patch.object(translation, "GoogleTranslator", BlockedTranslator), patch.object(
            translation, "_CLIENTS", {}
        ), patch.object(translation.time, "sleep") as sleep:
            with self.assertRaises(translation.TranslationRateLimitError):
                translation._translate("A new text", "tr")
        sleep.assert_called_once()

    def test_ollama_translates_locally_without_google_dependency(self):
        reply = io.BytesIO(json.dumps({
            "message": {"content": "Cause 2d6 + 3 de dano."},
            "done_reason": "stop",
        }).encode("utf-8"))
        with patch.object(translation, "TRANSLATION_PROVIDER", "ollama"), patch.object(
            translation, "GoogleTranslator", None
        ), patch.object(translation, "_TEXT_CACHE", {}), patch.object(
            translation, "urlopen", return_value=reply
        ) as request:
            result = translation._translate("Deal 2d6 + 3 damage.", "pt")
        self.assertEqual(result, "Cause 2d6 + 3 de dano.")
        sent = request.call_args.args[0]
        self.assertEqual(sent.full_url, translation.OLLAMA_API_URL)
        payload = json.loads(sent.data)
        self.assertEqual(payload["model"], "translategemma:4b")
        self.assertFalse(payload["stream"])
        self.assertNotIn("think", payload)
        self.assertIn("English (en) to Brazilian Portuguese (pt-BR)", payload["messages"][0]["content"])
        self.assertTrue(payload["messages"][0]["content"].endswith("\n\n\nDeal 2d6 + 3 damage."))

    def test_translategemma_uses_supported_spanish_code(self):
        prompt = translation._ollama_prompt("Deal 2d6 damage.", "es")
        self.assertIn("Spanish (es-MX)", prompt)
        self.assertNotIn("es-419", prompt)

    def test_qwen_retains_its_prompt_and_disables_thinking(self):
        reply = io.BytesIO(json.dumps({
            "message": {"content": "Cause 2d6 de dano."},
            "done_reason": "stop",
        }).encode("utf-8"))
        with patch.object(translation, "OLLAMA_MODEL", "qwen3.5:4b"), patch.object(
            translation, "urlopen", return_value=reply
        ) as request:
            self.assertEqual(translation._translate_ollama("Deal 2d6 damage.", "pt"), "Cause 2d6 de dano.")
        payload = json.loads(request.call_args.args[0].data)
        self.assertFalse(payload["think"])
        self.assertIn("Dungeons & Dragons SRD", payload["messages"][0]["content"])

    def test_ollama_rejects_changed_rules_text(self):
        for source, translated in (
            ("Deal 2d6 damage.", "Cause 3d6 de dano."),
            ("Gain {count} uses.", "Ganhe {amount} usos."),
            ("Use XARBPHX0X now.", "Use XARBPHX1X agora."),
        ):
            with self.subTest(source=source), patch.object(
                translation, "urlopen", return_value=io.BytesIO(json.dumps({
                    "message": {"content": translated}, "done_reason": "stop",
                }).encode("utf-8"))
            ):
                with self.assertRaises(translation.OllamaTranslationError) as error:
                    translation._translate_ollama(source, "pt")
                self.assertIn(f"Source: {source}", str(error.exception))
                self.assertIn(f"Candidate: {translated}", str(error.exception))
                self.assertEqual(error.exception.source, source)
                self.assertEqual(error.exception.candidate, translated)

    def test_ollama_failure_identifies_the_json_field(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "demo.json"
            with patch.dict(translation.EXTRACTORS, {"demo.json": lambda: {
                "Sword": {"name": "Sword", "description": "Deal 2d6 damage."},
            }}), patch.object(translation, "_translate", side_effect=[
                "Espada", translation.OllamaTranslationError("Changed numbers"),
            ]):
                with self.assertRaisesRegex(
                    translation.OllamaTranslationError, r"Field Sword\.description: Changed numbers"
                ):
                    translation.translate_file("demo.json", destination, "pt", merge=True)
            self.assertFalse(destination.exists())

    def test_ollama_connection_and_missing_model_errors_are_actionable(self):
        with patch.object(translation, "urlopen", side_effect=URLError("offline")):
            with self.assertRaisesRegex(translation.OllamaTranslationError, "Start the Ollama app"):
                translation._translate_ollama("Sword", "pt")
        missing = HTTPError(translation.OLLAMA_API_URL, 404, "not found", None, None)
        with patch.object(translation, "urlopen", side_effect=missing):
            with self.assertRaisesRegex(translation.OllamaTranslationError, "ollama pull translategemma:4b"):
                translation._translate_ollama("Sword", "pt")

    def test_ollama_rejects_empty_or_truncated_responses(self):
        for result in (
            {"message": {"content": ""}, "done_reason": "stop"},
            {"message": {"content": "Espada"}, "done_reason": "length"},
        ):
            with self.subTest(result=result), patch.object(
                translation, "urlopen", return_value=io.BytesIO(json.dumps(result).encode("utf-8"))
            ):
                with self.assertRaises(translation.OllamaTranslationError):
                    translation._translate_ollama("Sword", "pt")

    def test_ollama_dry_run_does_not_require_the_model(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(
            translation, "I18N_DIR", Path(directory)
        ), patch.object(translation, "SRD_DIR"), patch.object(
            translation, "TRANSLATION_PROVIDER", "google"
        ), patch.object(translation, "OLLAMA_MODEL", translation.DEFAULT_OLLAMA_MODEL), patch.object(
            translation, "validate_srd_pack", return_value=[]
        ), patch.dict(translation.EXTRACTORS, {
            "spells.json": lambda: {"Spell": {"name": "Spell"}},
        }, clear=True), patch.object(
            translation, "urlopen", side_effect=AssertionError("unexpected request")
        ), patch("sys.argv", ["translate_i18n.py", "pt", "--pack", "5.2.1", "--file",
                         "spells.json", "--merge", "--dry-run", "--provider", "ollama"]), patch(
            "builtins.print"
        ):
            translation.main()
            self.assertEqual(translation.TRANSLATION_PROVIDER, "ollama")
            self.assertEqual(translation.OLLAMA_MODEL, "translategemma:4b")
            self.assertFalse((Path(directory) / "pt/5.2.1/spells.json").exists())

    def test_output_dir_does_not_write_into_existing_overlays(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            overlays = root / "existing"
            review = root / "review"
            with patch.object(translation, "I18N_DIR", overlays), patch.object(
                translation, "SRD_DIR"
            ), patch.object(translation, "validate_srd_pack", return_value=[]), patch.dict(
                translation.EXTRACTORS, {"conditions.json": lambda: {
                    "Blinded": {"name": "Blinded"},
                }}, clear=True
            ), patch.object(translation, "_translate", return_value="Cego"), patch(
                "sys.argv", ["translate_i18n.py", "pt", "--pack", "5.2.1", "--file",
                             "conditions.json", "--merge", "--output-dir", str(review)]
            ), patch("builtins.print"):
                translation.main()
            self.assertEqual(json.loads((review / "pt/5.2.1/conditions.json").read_text()), {
                "Blinded": {"name": "Cego"},
            })
            self.assertFalse(overlays.exists())

    def test_failed_translation_saves_candidate_beside_review_draft(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            review = root / "review"
            name_reply = io.BytesIO(json.dumps({
                "message": {"content": "Paralisado"},
                "done_reason": "stop",
            }).encode("utf-8"))
            description_reply = io.BytesIO(json.dumps({
                "message": {"content": "Cause 3d6 de dano."},
                "done_reason": "stop",
            }).encode("utf-8"))
            with patch.object(translation, "I18N_DIR", root / "existing"), patch.object(
                translation, "SRD_DIR"
            ), patch.object(
                translation, "validate_srd_pack", return_value=[]
            ), patch.dict(translation.EXTRACTORS, {"conditions.json": lambda: {
                "Paralyzed": {"name": "Paralyzed", "description": "Deal 2d6 damage."},
            }}, clear=True), patch.object(
                translation, "urlopen", side_effect=[name_reply, description_reply]
            ), patch.object(
                translation, "_TEXT_CACHE", {}
            ), patch("sys.argv", [
                "translate_i18n.py", "pt", "--pack", "5.2.1", "--file",
                "conditions.json", "--merge", "--provider", "ollama",
                "--output-dir", str(review),
            ]), patch("builtins.print"):
                with self.assertRaises(translation.OllamaTranslationError):
                    translation.main()
            report = json.loads((review / "pt/5.2.1/conditions.review.json").read_text(encoding="utf-8"))
            self.assertEqual(report["field"], "Paralyzed.description")
            self.assertEqual(report["source"], "Deal 2d6 damage.")
            self.assertEqual(report["candidate"], "Cause 3d6 de dano.")
            self.assertEqual(report["json_entry_to_review"], {
                "Paralyzed": {
                    "name": "Paralisado",
                    "description": "Cause 3d6 de dano.",
                },
            })
            self.assertFalse((review / "pt/5.2.1/conditions.json").exists())
            self.assertFalse((root / "existing").exists())


if __name__ == "__main__":
    unittest.main()
