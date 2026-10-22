"""Offline tests for SRD overlay extraction and incremental translation."""

import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import translate_i18n as translation
from check_srd_i18n import missing_paths


class TranslationToolTests(unittest.TestCase):
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
            self.assertEqual(len(result), len(translation._srd("magic_items.json")))
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
        self.assertEqual(list(missing_paths(source, {})), [("choice", "name")])


if __name__ == "__main__":
    unittest.main()
