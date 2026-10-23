#!/usr/bin/env python3
"""
Generate SRD i18n overlay JSON files and Flutter ARB locale files for all locales
by translating English source data with Google Translate or a local Ollama model.

Usage (SRD overlays — assets/data/i18n/{locale}/{pack}/):
  python tools/translate_i18n.py                              # translate to ALL locales
  python tools/translate_i18n.py es fr de                     # translate to specific locales
  python tools/translate_i18n.py es --force                   # overwrite existing non-empty files
  python tools/translate_i18n.py --file equipment.json        # only translate equipment.json for all locales
  python tools/translate_i18n.py --file class_features.json --file feature_usages.json --force
  python tools/translate_i18n.py es --file equipment.json --force  # overwrite equipment.json for es
  python tools/translate_i18n.py pt --file feature_choices.json --force  # feature choice option labels
  python tools/translate_i18n.py --pack 5.1 --file magic_items.json --merge
  python tools/translate_i18n.py --pack 5.2.1 --merge
  python tools/translate_i18n.py tr --pack 5.1 --merge
  python tools/translate_i18n.py --pack 5.2.1 --merge --dry-run
  python tools/translate_i18n.py pt --pack 5.2.1 --file conditions.json --force --provider ollama
  python tools/translate_i18n.py pt --pack 5.2.1 --file conditions.json --merge --provider ollama --output-dir docs/private/translation-review
  python tools/translate_i18n.py pt --pack 5.2.1 --file spells.json --merge --provider ollama
  python tools/translate_i18n.py --pack 5.2.1 --merge --provider ollama --model qwen3.5:4b

Usage (ARB locale files — lib/l10n/):
  python tools/translate_i18n.py --arb                        # generate ARBs for ALL locales
  python tools/translate_i18n.py es fr --arb                  # generate ARBs for specific locales
  python tools/translate_i18n.py es --arb --force             # overwrite existing ARBs

Google provider requires: pip install deep-translator
Ollama provider requires: Ollama running locally with the selected model pulled.
"""

import json
import os
import random
import re
import sys
import time
from collections import Counter
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from validate_srd_pack import validate as validate_srd_pack

try:
    from deep_translator import GoogleTranslator
    from deep_translator.exceptions import TooManyRequests
except ImportError:
    GoogleTranslator = None

    class TooManyRequests(Exception):
        pass


# ── Paths ──────────────────────────────────────────────────────────────────────
ROOT     = Path(__file__).resolve().parent.parent
SRD_DIR  = ROOT / "assets" / "data" / "srd" / "5.1"
I18N_DIR = ROOT / "assets" / "data" / "i18n"
L10N_DIR = ROOT / "lib" / "l10n"

# ── Locale → Google Translate language code ────────────────────────────────────
LOCALE_LANG = {
    "pt": "pt",    # Portuguese
    "es": "es",    # Spanish
    "fr": "fr",    # French
    "de": "de",    # German
    "it": "it",    # Italian
    "ja": "ja",    # Japanese
    "ko": "ko",    # Korean
    "ru": "ru",    # Russian
    "tr": "tr",    # Turkish
    "zh": "zh-CN", # Chinese (Simplified)
}

OLLAMA_LANG = {
    "pt": "Brazilian Portuguese (pt-BR)",
    "es": "Latin American Spanish (es-419)",
    "fr": "French (fr-FR)",
    "de": "German (de-DE)",
    "it": "Italian (it-IT)",
    "ja": "Japanese (ja-JP)",
    "ko": "Korean (ko-KR)",
    "ru": "Russian (ru-RU)",
    "tr": "Turkish (tr-TR)",
    "zh-CN": "Simplified Chinese (zh-Hans)",
}

TRANSLATEGEMMA_LANG = {
    "pt": ("Brazilian Portuguese", "pt-BR"),
    "es": ("Spanish", "es-MX"),
    "fr": ("French", "fr-FR"),
    "de": ("German", "de-DE"),
    "it": ("Italian", "it-IT"),
    "ja": ("Japanese", "ja-JP"),
    "ko": ("Korean", "ko-KR"),
    "ru": ("Russian", "ru-RU"),
    "tr": ("Turkish", "tr-TR"),
    "zh-CN": ("Simplified Chinese", "zh-Hans"),
}

TRANSLATION_PROVIDER = "google"
DEFAULT_OLLAMA_MODEL = "translategemma:4b"
OLLAMA_MODEL = DEFAULT_OLLAMA_MODEL
OLLAMA_API_URL = "http://127.0.0.1:11434/api/chat"

# Delay between API calls (seconds). Increase if you hit rate limits.
DELAY_BASE   = 0.3
DELAY_JITTER = 0.15
MAX_RETRIES  = 3
_CLIENTS = {}
_TEXT_CACHE = {}
TECHNICAL_FIELDS = {"id", "type", "resourceId", "optionsSource", "formula"}


class TranslationRateLimitError(RuntimeError):
    pass


class OllamaTranslationError(RuntimeError):
    def __init__(
        self, message: str, *, source: str | None = None,
        candidate: str | None = None, field: str | None = None,
        preview=None,
    ):
        super().__init__(message)
        self.source = source
        self.candidate = candidate
        self.field = field
        self.preview = preview


# ── SRD extractors ─────────────────────────────────────────────────────────────
# Each function reads SRD data and produces the canonical EN overlay structure:
#   keys = English identifiers (never translated)
#   values = { "name": EN string, "description": EN string, … }

def _srd(filename: str):
    return json.loads((SRD_DIR / filename).read_text(encoding="utf-8"))


def extract_skills() -> dict:
    # srd: [{ name, ability }]
    return {item["name"]: {"name": item["name"]} for item in _srd("skills.json")}


def extract_equipment() -> dict:
    # srd: { weapons: [...], armor: [...], gear: [...] }
    out = {}
    source = _srd("equipment.json")
    for category in source.values():
        if isinstance(category, list):
            for item in category:
                if isinstance(item, dict) and "name" in item:
                    entry = {"name": item["name"]}
                    if item.get("description"):
                        entry["description"] = item["description"]
                    out[item["name"]] = entry
    if SRD_DIR.name == "5.2.1":
        out["weaponMasteries"] = {
            mastery: {"name": mastery.title(), "description": description}
            for mastery, description in source.get("weaponMasteries", {}).items()
        }
    return out


def extract_magic_items() -> dict:
    # srd: [{ name, description, … }]
    return {
        item["name"]: {"name": item["name"], "description": item.get("description", "")}
        for item in _srd("magic_items.json")
    }


def extract_race_traits() -> dict:
    # srd: { "TraitName": "description text" }
    return {k: {"name": k, "description": v} for k, v in _srd("race_traits.json").items()}


def extract_races() -> dict:
    # srd: [{ name, languages: [...], subraces: [{ name }] }]
    out = {}
    for race in _srd("races.json"):
        if SRD_DIR.name == "5.2.1":
            out[race["name"]] = {"name": race["name"]}
        else:
            out[race["name"]] = {
                "name": race["name"],
                "languages": race.get("languages", []),
                "subraces": [{"name": sr["name"]} for sr in race.get("subraces", [])],
            }
    return out


def extract_backgrounds() -> dict:
    # srd: [{ name, startingEquipment: [...], feature: { name, description } }]
    out = {}
    for bg in _srd("backgrounds.json"):
        if SRD_DIR.name == "5.2.1":
            out[bg["name"]] = {"name": bg["name"]}
            continue
        entry = {
            "name": bg["name"],
            "startingEquipment": bg.get("startingEquipment", []),
        }
        if "feature" in bg:
            entry["feature"] = {
                "name": bg["feature"]["name"],
                "description": bg["feature"]["description"],
            }
        out[bg["name"]] = entry
    return out


def extract_classes() -> dict:
    # srd: [{ name, subclassFeatureName, weaponProficiencies,
    #         startingEquipment: { fixed: [...], choices: [{ options: [[...]] }] } }]
    out = {}
    for cls in _srd("classes.json"):
        if SRD_DIR.name == "5.2.1":
            out[cls["name"]] = {
                "name": cls["name"],
                "subclassFeatureName": cls.get("subclassFeatureName", ""),
            }
            continue
        entry = {
            "name": cls["name"],
            "subclassFeatureName": cls.get("subclassFeatureName", ""),
            "weaponProficiencies": cls.get("weaponProficiencies", []),
            "startingEquipment": cls.get("startingEquipment", {}),
        }
        out[cls["name"]] = entry
    return out


def extract_spells() -> dict:
    # srd: [{ name, description, higherLevels, material, … }]
    out = {
        spell["name"]: {
            "name": spell["name"],
            "description": spell.get("description", ""),
            "higherLevels": spell.get("higherLevels"),
            "material": spell.get("material"),
        }
        for spell in _srd("spells.json")
    }
    if SRD_DIR.name == "5.2.1":
        for spell in _srd("spells.json"):
            entry = out[spell["name"]]
            for field in ("castingTime", "range", "duration"):
                if spell.get(field):
                    entry[field] = spell[field]
            labels = {
                roll["id"]: {"label": roll["label"]}
                for roll in spell.get("rolls", [])
                if roll.get("label")
            }
            if labels:
                entry["rolls"] = labels
    return out


def extract_subclasses() -> dict:
    # srd: { "Class": [{ name, description }] }
    return {
        cls: {s["name"]: {"name": s["name"], "description": s.get("description", "")} for s in subs}
        for cls, subs in _srd("subclasses.json").items()
    }


def extract_class_features() -> dict:
    # srd: [{ class, features: [{ name, description }] }]
    out = {}
    for entry in _srd("class_features.json"):
        cls = entry["class"]
        out[cls] = {
            f["name"]: {"name": f["name"], "description": f.get("description", "")}
            for f in entry.get("features", [])
        }
    return out


def extract_subclass_features() -> dict:
    # srd: [{ class, subclass, features: [{ name, description }] }]
    out = {}
    for entry in _srd("subclass_features.json"):
        cls = entry["class"]
        sub = entry["subclass"]
        out.setdefault(cls, {})[sub] = {
            f["name"]: {"name": f["name"], "description": f.get("description", "")}
            for f in entry.get("features", [])
        }
    return out


def extract_languages() -> dict:
    # srd: [{ name }]
    return {lang["name"]: {"name": lang["name"]} for lang in _srd("languages.json")}


def extract_tools() -> dict:
    # srd: [{ name }]
    return {tool["name"]: {"name": tool["name"]} for tool in _srd("tools.json")}


def extract_feats() -> dict:
    # srd: [{ name, prerequisite, description }]
    out = {}
    for feat in _srd("feats.json"):
        entry = {"name": feat["name"], "description": feat.get("description", "")}
        if SRD_DIR.name == "5.1":
            entry["prerequisite"] = feat.get("prerequisite")
        out[feat["name"]] = entry
    return out


def extract_conditions() -> dict:
    # srd: [{ name, description }]
    return {
        c["name"]: {"name": c["name"], "description": c["description"]}
        for c in _srd("conditions.json")
    }


# Map filename → extractor function
def _extract_feature_choice_options(options: list) -> dict:
    out = {}
    for option in options:
        if not isinstance(option, dict) or "id" not in option:
            continue
        entry = {}
        if option.get("name"):
            entry["name"] = option["name"]
        if option.get("description"):
            entry["description"] = option["description"]
        if entry:
            out[option["id"]] = entry
    return out


def _extract_feature_choice_definitions(definitions: dict) -> dict:
    out = {}
    for name, definition in definitions.items():
        choices = {}
        for choice in definition.get("choices", []):
            inline_options = _extract_feature_choice_options(choice.get("options", []))
            if inline_options:
                choices[choice["id"]] = {"options": inline_options}
        if choices:
            out[name] = {"choices": choices}
    return out


def _extract_feature_choice_definition_map(node) -> dict:
    if not isinstance(node, dict):
        return {}
    if "choices" in node:
        extracted = _extract_feature_choice_definitions({"_": node})
        return extracted.get("_", {})
    out = {}
    for key, value in node.items():
        extracted = _extract_feature_choice_definition_map(value)
        if extracted:
            out[key] = extracted
    return out


def extract_feature_choices() -> dict:
    # feature_choices.json mixes rule metadata with player-facing option
    # labels. Keep technical IDs/keys in English and translate only option
    # names/descriptions.
    src = _srd("feature_choices.json")
    out = {}

    option_sources = {}
    for source_name, options in src.get("optionSources", {}).items():
        extracted = _extract_feature_choice_options(options)
        if extracted:
            option_sources[source_name] = extracted
    if option_sources:
        out["optionSources"] = option_sources

    for section in ("classFeatures", "subclassFeatures", "raceTraits", "feats"):
        extracted = _extract_feature_choice_definition_map(src.get(section, {}))
        if extracted:
            out[section] = extracted

    return out


def extract_feature_usages() -> dict:
    # feature_usages.json mixes rule metadata with player-facing resource
    # labels. Keep IDs/formulas/recharge rules in SRD and translate only names.
    resources = {}
    for resource_id, resource in _srd("feature_usages.json").get(
        "resources", {}
    ).items():
        if not isinstance(resource, dict):
            continue
        entry = {}
        if resource.get("name"):
            entry["name"] = resource["name"]
        if resource.get("description"):
            entry["description"] = resource["description"]
        if entry:
            resources[resource_id] = entry
    return {"resources": resources} if resources else {}


EXTRACTORS = {
    "languages.json":         extract_languages,
    "tools.json":             extract_tools,
    "feats.json":             extract_feats,
    "conditions.json":        extract_conditions,
    "feature_choices.json":   extract_feature_choices,
    "feature_usages.json":    extract_feature_usages,
    "skills.json":            extract_skills,
    "equipment.json":         extract_equipment,
    "magic_items.json":       extract_magic_items,
    "race_traits.json":       extract_race_traits,
    "races.json":             extract_races,
    "backgrounds.json":       extract_backgrounds,
    "classes.json":           extract_classes,
    "spells.json":            extract_spells,
    "subclasses.json":        extract_subclasses,
    "class_features.json":    extract_class_features,
    "subclass_features.json": extract_subclass_features,
}


# ── Translation helpers ────────────────────────────────────────────────────────

def _translation_chunks(text: str, limit: int = 4500) -> list[str]:
    if len(text) <= limit:
        return [text]
    parts = re.split(r"(\n\n|(?<=[.!?])\s+)", text)
    chunks = []
    current = ""
    for part in parts:
        if len(current) + len(part) > limit and current:
            chunks.append(current)
            current = ""
        if len(part) > limit:
            words = re.split(r"(\s+)", part)
            for word in words:
                if len(current) + len(word) > limit and current:
                    chunks.append(current)
                    current = ""
                current += word
        else:
            current += part
    if current:
        chunks.append(current)
    return chunks


def _protected_tokens(text: str):
    return (
        Counter(re.findall(r"\{[^{}]+\}", text)),
        Counter(
            token.lower()
            for token in re.findall(r"\b(?:[0-9]+)?d[0-9]+\b", text, re.I)
        ),
        Counter(re.findall(r"[0-9]+", text)),
        Counter(re.findall(r"XARBPHX[0-9]+X", text)),
    )


def _ollama_prompt(text: str, tgt: str) -> str:
    if OLLAMA_MODEL.lower().split(":", 1)[0] == "translategemma":
        language, code = TRANSLATEGEMMA_LANG[tgt]
        return (
            f"You are a professional English (en) to {language} ({code}) translator. "
            "Your goal is to accurately convey the meaning and nuances of the original "
            f"English text while adhering to {language} grammar, vocabulary, and cultural "
            f"sensitivities. Produce only the {language} translation, without any "
            "additional explanations or commentary. Please translate the following "
            f"English text into {language}:\n\n\n{text}"
        )
    language = OLLAMA_LANG[tgt]
    return (
        f"Translate this Dungeons & Dragons SRD text from English to {language}. "
        "Return only the translation, without quotes or commentary. "
        "Preserve every number, dice expression (such as 2d6), placeholder, "
        "XARBPHX token, and line break exactly. Do not add or remove rules.\n\n"
        f"{text}"
    )


def _translate_ollama(text: str, tgt: str) -> str:
    payload_data = {
        "model": OLLAMA_MODEL,
        "messages": [{"role": "user", "content": _ollama_prompt(text, tgt)}],
        "stream": False,
        "options": {"temperature": 0, "num_ctx": 4096},
    }
    if OLLAMA_MODEL.lower().split(":", 1)[0] != "translategemma":
        payload_data["think"] = False
    payload = json.dumps(payload_data, ensure_ascii=False).encode("utf-8")
    request = Request(
        OLLAMA_API_URL,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urlopen(request, timeout=180) as response:
            result = json.load(response)
    except HTTPError as exc:
        if exc.code == 404:
            raise OllamaTranslationError(
                f"Ollama could not find {OLLAMA_MODEL!r}. Run: ollama pull {OLLAMA_MODEL}"
            ) from exc
        raise OllamaTranslationError(f"Ollama returned HTTP {exc.code}") from exc
    except (URLError, TimeoutError) as exc:
        raise OllamaTranslationError(
            "Cannot reach Ollama at 127.0.0.1:11434 or the request timed out. "
            "Start the Ollama app first."
        ) from exc
    except (ValueError, UnicodeError) as exc:
        raise OllamaTranslationError("Ollama returned invalid JSON") from exc

    message = result.get("message") if isinstance(result, dict) else None
    translated = message.get("content") if isinstance(message, dict) else None
    if not isinstance(translated, str) or not translated.strip():
        raise OllamaTranslationError("Ollama returned an empty translation")
    if result.get("done_reason") == "length":
        raise OllamaTranslationError("Ollama truncated the translation")
    translated = translated.strip()
    original_tokens = _protected_tokens(text)
    translated_tokens = _protected_tokens(translated)
    if translated_tokens != original_tokens:
        labels = ("placeholders", "dice", "numbers", "ARB tokens")
        changed = ", ".join(
            label for label, before, after in zip(
                labels, original_tokens, translated_tokens
            ) if before != after
        )
        raise OllamaTranslationError(
            f"Ollama changed protected {changed}; this entry was not saved.\n"
            f"Source: {text}\nCandidate: {translated}\n"
            "Correct the entry manually, then resume with --merge.",
            source=text,
            candidate=translated,
        )
    return translated


def _translate(text: str, tgt: str) -> str:
    """Translate an English string using the selected provider."""
    if not text or not text.strip():
        return text
    if len(text) > 4500:
        paragraphs = text.split("\n\n")
        if len(paragraphs) > 1:
            return "\n\n".join(_translate(part, tgt) for part in paragraphs)
        return " ".join(_translate(chunk.strip(), tgt) for chunk in _translation_chunks(text))
    cache_key = (
        TRANSLATION_PROVIDER,
        OLLAMA_MODEL if TRANSLATION_PROVIDER == "ollama" else None,
        tgt,
        text,
    )
    if cache_key in _TEXT_CACHE:
        return _TEXT_CACHE[cache_key]
    if TRANSLATION_PROVIDER == "ollama":
        result = _translate_ollama(text, tgt)
        _TEXT_CACHE[cache_key] = result
        return result
    if GoogleTranslator is None:
        raise RuntimeError("deep-translator is required: pip install deep-translator")
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            time.sleep(DELAY_BASE + random.uniform(0, DELAY_JITTER))
            if tgt not in _CLIENTS:
                _CLIENTS[tgt] = GoogleTranslator(source="en", target=tgt)
            client = _CLIENTS[tgt]
            result = client.translate(text)
            if not result:
                raise RuntimeError("translation service returned an empty result")
            _TEXT_CACHE[cache_key] = result
            return result
        except TooManyRequests as exc:
            raise TranslationRateLimitError(
                "Google Translate blocked the request (HTTP 429). "
                "The free deep-translator endpoint is not reliable for a full SRD pack. "
                "No in-progress entry was saved; rerun --merge after choosing a scalable translator."
            ) from exc
        except Exception as exc:
            wait = 2 ** attempt
            print(f"\n    [retry {attempt}/{MAX_RETRIES}] {exc} — waiting {wait}s")
            time.sleep(wait)
    raise RuntimeError(f"Translation failed after {MAX_RETRIES} attempts: {text[:60]!r}")


# ── File handling ──────────────────────────────────────────────────────────────

def _merge_translations(source, existing, tgt_lang: str, path: tuple = ()):
    if isinstance(source, dict):
        result = dict(existing) if isinstance(existing, dict) else {}
        for key, value in source.items():
            try:
                result[key] = (
                    value if key in TECHNICAL_FIELDS
                    else _merge_translations(value, result.get(key), tgt_lang, (*path, key))
                )
            except OllamaTranslationError as exc:
                if exc.preview is not None:
                    result[key] = exc.preview
                exc.preview = result
                raise
        return result
    if isinstance(source, list):
        result = list(existing) if isinstance(existing, list) else []
        for index, value in enumerate(source):
            old = result[index] if index < len(result) else None
            try:
                merged = _merge_translations(value, old, tgt_lang, (*path, index))
            except OllamaTranslationError as exc:
                if exc.preview is not None:
                    if index < len(result):
                        result[index] = exc.preview
                    else:
                        result.append(exc.preview)
                exc.preview = result
                raise
            if index < len(result):
                result[index] = merged
            else:
                result.append(merged)
        return result
    if isinstance(source, str):
        if isinstance(existing, str) and existing.strip():
            return existing
        try:
            return _translate(source, tgt_lang)
        except OllamaTranslationError as exc:
            field = ".".join(map(str, path))
            raise OllamaTranslationError(
                f"Field {field}: {exc}", source=exc.source,
                candidate=exc.candidate, field=field, preview=exc.candidate,
            ) from exc
    return existing if existing is not None else source


def _missing_text_values(source, existing):
    if isinstance(source, dict):
        old = existing if isinstance(existing, dict) else {}
        for key, value in source.items():
            if key not in TECHNICAL_FIELDS:
                yield from _missing_text_values(value, old.get(key))
    elif isinstance(source, list):
        old = existing if isinstance(existing, list) else []
        for index, value in enumerate(source):
            yield from _missing_text_values(value, old[index] if index < len(old) else None)
    elif isinstance(source, str) and source.strip() and (
        not isinstance(existing, str) or not existing.strip()
    ):
        yield source


def _missing_text_count(source, existing) -> int:
    return sum(1 for _ in _missing_text_values(source, existing))


def _write_json(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    os.replace(temporary, path)


def translate_file(filename: str, dst_path: Path, tgt_lang: str, *, merge: bool = False):
    source = EXTRACTORS[filename]()
    existing = json.loads(dst_path.read_text(encoding="utf-8")) if merge and dst_path.exists() else {}
    if not isinstance(existing, dict):
        raise ValueError(f"Expected an object in {dst_path}")
    result = dict(existing)
    for key, value in source.items():
        previous = result.get(key)
        if merge and filename in {
            "class_features.json", "subclass_features.json",
            "feature_choices.json", "feature_usages.json",
        } and isinstance(value, dict):
            group = dict(previous) if isinstance(previous, dict) else {}
            for child_key, child_value in value.items():
                old = group.get(child_key)
                if _missing_text_count(child_value, old) == 0:
                    continue
                try:
                    group[child_key] = _merge_translations(
                        child_value, old, tgt_lang, (child_key,)
                    )
                except OllamaTranslationError as exc:
                    exc.preview = {key: {child_key: exc.preview}}
                    raise
                result[key] = group
                _write_json(dst_path, result)
            continue
        if merge and _missing_text_count(value, previous) == 0:
            continue
        try:
            result[key] = _merge_translations(
                value, previous if merge else None, tgt_lang, (key,)
            )
        except OllamaTranslationError as exc:
            exc.preview = {key: exc.preview}
            raise
        if merge:
            _write_json(dst_path, result)
    if not merge or not dst_path.exists():
        _write_json(dst_path, result)


def is_empty(path: Path) -> bool:
    if not path.exists():
        return True
    content = path.read_text(encoding="utf-8").strip()
    return not content or content in ("{}", "[]", "")


# ── ARB translation ────────────────────────────────────────────────────────────

# Pattern for ICU-style placeholders: {name}, {level}, {count}, etc.
_PLACEHOLDER_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")
# Token template: something Google won't touch (all-caps, no spaces)
_TOKEN_FMT = "XARBPHX{i}X"


def _translate_arb_string(text: str, tgt_lang: str) -> str:
    """
    Translate an ARB string value while preserving {placeholder} tokens.
    Also skips translation for strings that contain no translatable content
    (e.g. pure symbols / punctuation / empty).
    """
    if not text or not text.strip():
        return text

    # Extract and replace placeholders with safe sentinel tokens.
    # Wrap each token in spaces so Google doesn't merge it with adjacent words;
    # we'll collapse any resulting double-spaces after restoration.
    placeholders: list[str] = _PLACEHOLDER_RE.findall(text)
    tokenized = text
    token_map: dict[str, str] = {}
    for i, ph in enumerate(placeholders):
        token = _TOKEN_FMT.format(i=i)
        token_map[token] = ph
        tokenized = tokenized.replace(ph, f" {token} ", 1)

    translated = _translate(tokenized, tgt_lang)

    # Restore placeholder tokens
    for token, ph in token_map.items():
        translated = translated.replace(token, ph)

    # Collapse any double-spaces introduced by the padding
    translated = re.sub(r"  +", " ", translated).strip()

    return translated


def translate_arb(locale: str, tgt_lang: str, force: bool):
    """
    Translate lib/l10n/app_en.arb → lib/l10n/app_{locale}.arb.
    Metadata keys (@xxx) are copied verbatim; @@locale is updated.
    """
    src_arb = L10N_DIR / "app_en.arb"
    dst_arb = L10N_DIR / f"app_{locale}.arb"

    if not src_arb.exists():
        print(f"  app_en.arb not found at {src_arb}")
        return

    if not force and not is_empty(dst_arb):
        print(f"  app_{locale}.arb            SKIP (use --force to overwrite)")
        return

    print(f"  app_{locale}.arb            ", end="", flush=True)

    src: dict = json.loads(src_arb.read_text(encoding="utf-8"))
    out: dict = {}

    for key, value in src.items():
        if key == "@@locale":
            out["@@locale"] = locale
            continue
        if key.startswith("@"):
            # Skip all metadata blocks — Flutter reads them from app_en.arb
            continue
        if isinstance(value, str):
            try:
                out[key] = _translate_arb_string(value, tgt_lang)
            except OllamaTranslationError as exc:
                raise OllamaTranslationError(
                    f"ARB key {key}: {exc}", source=exc.source,
                    candidate=exc.candidate, field=key,
                ) from exc
        else:
            out[key] = value

    dst_arb.write_text(
        json.dumps(out, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("done")


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    global SRD_DIR, TRANSLATION_PROVIDER, OLLAMA_MODEL
    raw_args = sys.argv[1:]
    force    = "--force" in raw_args
    arb_mode = "--arb"   in raw_args
    merge    = "--merge" in raw_args
    dry_run  = "--dry-run" in raw_args
    args     = [a for a in raw_args if a not in ("--force", "--arb", "--merge", "--dry-run")]
    if force and merge:
        print("Use either --force (replace translations) or --merge (keep existing translations)")
        sys.exit(1)
    if arb_mode and (merge or dry_run):
        print("--merge and --dry-run are only available for SRD overlays")
        sys.exit(1)

    provider = "google"
    if "--provider" in args:
        idx = args.index("--provider")
        if idx + 1 >= len(args) or args[idx + 1].startswith("--"):
            print("--provider requires google or ollama")
            sys.exit(1)
        provider = args[idx + 1]
        args = args[:idx] + args[idx + 2:]
    if provider not in ("google", "ollama"):
        print("--provider must be google or ollama")
        sys.exit(1)

    model = DEFAULT_OLLAMA_MODEL
    if "--model" in args:
        idx = args.index("--model")
        if idx + 1 >= len(args) or args[idx + 1].startswith("--"):
            print("--model requires an Ollama model name")
            sys.exit(1)
        model = args[idx + 1]
        args = args[:idx] + args[idx + 2:]
        if provider != "ollama":
            print("--model requires --provider ollama")
            sys.exit(1)
    if provider == "ollama" and model.endswith(":cloud"):
        print("Only local Ollama models are supported by this translation tool")
        sys.exit(1)
    TRANSLATION_PROVIDER = provider
    OLLAMA_MODEL = model

    output_dir = I18N_DIR
    if "--output-dir" in args:
        idx = args.index("--output-dir")
        if idx + 1 >= len(args) or args[idx + 1].startswith("--"):
            print("--output-dir requires a directory path")
            sys.exit(1)
        output_dir = Path(args[idx + 1])
        args = args[:idx] + args[idx + 2:]
        if arb_mode:
            print("--output-dir is only available for SRD overlays")
            sys.exit(1)

    pack = "5.1"
    if "--pack" in args:
        idx = args.index("--pack")
        if idx + 1 >= len(args):
            print("--pack requires 5.1 or 5.2.1")
            sys.exit(1)
        pack = args[idx + 1]
        args = args[:idx] + args[idx + 2:]
    if pack not in ("5.1", "5.2.1"):
        print("--pack must be 5.1 or 5.2.1")
        sys.exit(1)

    # --file equipment.json  → translate only that SRD file
    file_filters = []
    while "--file" in args:
        idx = args.index("--file")
        if idx + 1 >= len(args):
            print("--file requires a filename")
            sys.exit(1)
        file_filters.extend(
            part.strip()
            for part in args[idx + 1].split(",")
            if part.strip()
        )
        args = args[:idx] + args[idx + 2:]

    if args:
        target_locales = args
        unknown = [l for l in target_locales if l not in LOCALE_LANG]
        if unknown:
            print(f"Unknown locale(s): {', '.join(unknown)}")
            print(f"Supported: {', '.join(LOCALE_LANG.keys())}")
            sys.exit(1)
    else:
        target_locales = list(LOCALE_LANG.keys())

    # ── ARB mode ──────────────────────────────────────────────────────────────
    if arb_mode:
        print(f"Source : {L10N_DIR / 'app_en.arb'}")
        print(f"Targets: {', '.join(target_locales)}")
        print(f"Provider: {provider}{f' ({model})' if provider == 'ollama' else ''}")
        print(f"Force  : {force}\n")
        for locale in target_locales:
            tgt_lang = LOCALE_LANG[locale]
            print(f"{'='*60}")
            print(f"Translating ARB to '{locale}' ({tgt_lang})")
            print(f"{'='*60}")
            translate_arb(locale, tgt_lang, force)
        print(f"\n{'='*60}")
        print("ARB translations complete.")
        return

    # ── SRD overlay mode ──────────────────────────────────────────────────────
    SRD_DIR = ROOT / "assets" / "data" / "srd" / pack
    integrity_errors = validate_srd_pack(pack)
    if integrity_errors:
        print("English SRD pack failed validation:")
        for error in integrity_errors:
            print(f"  {error}")
        sys.exit(1)
    filenames = sorted(EXTRACTORS.keys())
    if file_filters:
        unknown_files = [f for f in file_filters if f not in EXTRACTORS]
        if unknown_files:
            print(
                f"Unknown file(s): {', '.join(unknown_files)}. "
                f"Available: {', '.join(sorted(EXTRACTORS.keys()))}"
            )
            sys.exit(1)
        filenames = list(dict.fromkeys(file_filters))

    missing_sources = [name for name in filenames if not (SRD_DIR / name).is_file()]
    if missing_sources:
        print(f"Missing English SRD files for {pack}: {', '.join(missing_sources)}")
        sys.exit(1)

    print(f"Source : {SRD_DIR} (English SRD)")
    print(f"Targets: {', '.join(target_locales)} in {output_dir}")
    print(f"Provider: {provider}{f' ({model})' if provider == 'ollama' else ''}")
    print(f"Mode   : {'force' if force else 'merge' if merge else 'skip existing'}")
    print(f"Dry run: {dry_run}\n")

    for locale in target_locales:
        tgt_lang = LOCALE_LANG[locale]
        tgt_dir  = output_dir / locale / pack
        print(f"{'='*60}")
        print(f"Translating to '{locale}' ({tgt_lang})")
        print(f"{'='*60}")

        for filename in filenames:
            dst_file = tgt_dir / filename
            if not force and not merge and not is_empty(dst_file):
                print(f"  {filename:<30} SKIP (use --force to overwrite)")
                continue
            if dry_run:
                existing = json.loads(dst_file.read_text(encoding="utf-8")) if merge and dst_file.exists() else {}
                texts = _missing_text_values(EXTRACTORS[filename](), existing)
                count = characters = 0
                for value in texts:
                    count += 1
                    characters += len(value)
                print(f"  {filename:<30} {count} text fields / {characters} characters")
                continue
            print(f"  {filename:<30} ", end="", flush=True)
            try:
                translate_file(filename, dst_file, tgt_lang, merge=merge)
            except OllamaTranslationError as exc:
                review_root = (
                    output_dir if output_dir != I18N_DIR
                    else ROOT / "docs" / "private" / "translation-review"
                )
                review_path = review_root / locale / pack / f"{Path(filename).stem}.review.json"
                _write_json(review_path, {
                    "file": filename,
                    "field": exc.field,
                    "reason": str(exc).splitlines()[0],
                    "source": exc.source,
                    "candidate": exc.candidate,
                    "json_entry_to_review": exc.preview,
                })
                print(f"\nReview saved: {review_path.resolve()}", file=sys.stderr, flush=True)
                raise
            print("done")

    print(f"\n{'='*60}")
    print("Dry run complete; no translations written." if dry_run else "All translations complete.")


if __name__ == "__main__":
    try:
        main()
    except (TranslationRateLimitError, OllamaTranslationError) as exc:
        print(f"\nERROR: {exc}", file=sys.stderr)
        sys.exit(2)
