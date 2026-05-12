#!/usr/bin/env python3
"""
Generate SRD i18n overlay JSON files for all locales by translating directly
from the English SRD source data (assets/data/srd/*.json).

Keys in overlay files are always English identifiers — never translated.
All string VALUES are translated from English to the target language.

Usage:
  python tools/translate_i18n.py              # translate to ALL locales
  python tools/translate_i18n.py es fr de     # translate to specific locales
  python tools/translate_i18n.py es --force   # overwrite existing non-empty files

Requires:
  pip install deep-translator
"""

import json
import sys
import time
import random
from pathlib import Path

try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("ERROR: deep-translator not installed. Run: pip install deep-translator")
    sys.exit(1)


# ── Paths ──────────────────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent
SRD_DIR  = ROOT / "assets" / "data" / "srd"
I18N_DIR = ROOT / "assets" / "data" / "i18n"

# ── Locale → Google Translate language code ────────────────────────────────────
LOCALE_LANG = {
    "es": "es",    # Spanish
    "fr": "fr",    # French
    "de": "de",    # German
    "it": "it",    # Italian
    "ja": "ja",    # Japanese
    "ko": "ko",    # Korean
    "ru": "ru",    # Russian
    "zh": "zh-CN", # Chinese (Simplified)
}

# Delay between API calls (seconds). Increase if you hit rate limits.
DELAY_BASE   = 0.3
DELAY_JITTER = 0.15
MAX_RETRIES  = 3


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
    # srd: { weapons: [...], armor: [...], adventuringGear: [...] }
    out = {}
    for category in _srd("equipment.json").values():
        if isinstance(category, list):
            for item in category:
                if isinstance(item, dict) and "name" in item:
                    out[item["name"]] = {"name": item["name"]}
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
        entry = {
            "name": cls["name"],
            "subclassFeatureName": cls.get("subclassFeatureName", ""),
            "weaponProficiencies": cls.get("weaponProficiencies", []),
            "startingEquipment": cls.get("startingEquipment", {}),
        }
        out[cls["name"]] = entry
    return out


def extract_spells() -> dict:
    # srd: [{ name, description, higherLevels, … }]
    return {
        spell["name"]: {
            "name": spell["name"],
            "description": spell.get("description", ""),
            "higherLevels": spell.get("higherLevels"),
        }
        for spell in _srd("spells.json")
    }


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


# Map filename → extractor function
EXTRACTORS = {
    "languages.json":         extract_languages,
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

def _translate(text: str, tgt: str) -> str:
    """Translate an English string to tgt language with retries."""
    if not text or not text.strip():
        return text
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            time.sleep(DELAY_BASE + random.uniform(0, DELAY_JITTER))
            result = GoogleTranslator(source="en", target=tgt).translate(text)
            return result if result else text
        except Exception as exc:
            wait = 2 ** attempt
            print(f"\n    [retry {attempt}/{MAX_RETRIES}] {exc} — waiting {wait}s")
            time.sleep(wait)
    print(f"\n    [WARN] Giving up on: {text[:60]!r}")
    return text


def _translate_node(node, tgt_lang: str):
    """
    Recursively translate all string VALUES from English.
    Dict KEYS are English identifiers — never translated.
    None / bool / int / float — kept as-is.
    """
    if isinstance(node, dict):
        return {k: _translate_node(v, tgt_lang) for k, v in node.items()}
    if isinstance(node, list):
        return [_translate_node(item, tgt_lang) for item in node]
    if isinstance(node, str):
        return _translate(node, tgt_lang)
    return node  # None, bool, int, float


# ── File handling ──────────────────────────────────────────────────────────────

def translate_file(filename: str, dst_path: Path, tgt_lang: str):
    extractor = EXTRACTORS[filename]
    en_overlay = extractor()
    translated = _translate_node(en_overlay, tgt_lang)
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    dst_path.write_text(
        json.dumps(translated, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def is_empty(path: Path) -> bool:
    if not path.exists():
        return True
    content = path.read_text(encoding="utf-8").strip()
    return not content or content in ("{}", "[]", "")


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    raw_args = sys.argv[1:]
    force = "--force" in raw_args
    args  = [a for a in raw_args if a != "--force"]

    if args:
        target_locales = args
        unknown = [l for l in target_locales if l not in LOCALE_LANG]
        if unknown:
            print(f"Unknown locale(s): {', '.join(unknown)}")
            print(f"Supported: {', '.join(LOCALE_LANG.keys())}")
            sys.exit(1)
    else:
        target_locales = list(LOCALE_LANG.keys())

    filenames = sorted(EXTRACTORS.keys())

    print(f"Source : {SRD_DIR} (English SRD)")
    print(f"Targets: {', '.join(target_locales)}")
    print(f"Force  : {force}\n")

    for locale in target_locales:
        tgt_lang = LOCALE_LANG[locale]
        tgt_dir  = I18N_DIR / locale
        print(f"{'='*60}")
        print(f"Translating to '{locale}' ({tgt_lang})")
        print(f"{'='*60}")

        for filename in filenames:
            dst_file = tgt_dir / filename
            if not force and not is_empty(dst_file):
                print(f"  {filename:<30} SKIP (use --force to overwrite)")
                continue
            print(f"  {filename:<30} ", end="", flush=True)
            translate_file(filename, dst_file, tgt_lang)
            print("done")

    print(f"\n{'='*60}")
    print("All translations complete.")


if __name__ == "__main__":
    main()
