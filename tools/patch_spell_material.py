#!/usr/bin/env python3
"""
Patch spell i18n JSON files with translated 'material' field only.

Reads assets/data/srd/spells.json for spells that have a material component,
then for each locale, translates only the missing 'material' field and merges
it into the existing assets/data/i18n/{locale}/spells.json without touching
any other field (name, description, higherLevels, etc.).

Usage:
  python tools/patch_spell_material.py              # all locales
  python tools/patch_spell_material.py pt es fr     # specific locales
  python tools/patch_spell_material.py pt --force   # re-translate already filled entries

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

ROOT     = Path(__file__).resolve().parent.parent
SRD_DIR  = ROOT / "assets" / "data" / "srd"
I18N_DIR = ROOT / "assets" / "data" / "i18n"

LOCALE_LANG = {
    "pt": "pt",
    "es": "es",
    "fr": "fr",
    "de": "de",
    "it": "it",
    "ja": "ja",
    "ko": "ko",
    "ru": "ru",
    "zh": "zh-CN",
}

DELAY_BASE   = 0.3
DELAY_JITTER = 0.15
MAX_RETRIES  = 3


def _translate(text: str, tgt: str) -> str:
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


def patch_locale(locale: str, tgt_lang: str, force: bool):
    spells_path = I18N_DIR / locale / "spells.json"
    srd_spells  = json.loads((SRD_DIR / "spells.json").read_text(encoding="utf-8"))

    # Load existing i18n file or start empty
    existing: dict = {}
    if spells_path.exists():
        existing = json.loads(spells_path.read_text(encoding="utf-8"))

    patched = 0
    skipped = 0

    for spell in srd_spells:
        name     = spell["name"]
        material = spell.get("material")

        if not material:
            continue  # no material component — nothing to do

        entry = existing.setdefault(name, {})

        if not force and entry.get("material"):
            skipped += 1
            continue  # already translated

        translated = _translate(material, tgt_lang)
        entry["material"] = translated
        patched += 1
        print(f"    [{locale}] {name}: {translated}")

    spells_path.parent.mkdir(parents=True, exist_ok=True)
    spells_path.write_text(
        json.dumps(existing, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"  → {locale}: {patched} patched, {skipped} skipped\n")


def main():
    args  = sys.argv[1:]
    force = "--force" in args
    args  = [a for a in args if a != "--force"]

    if args:
        target_locales = args
        unknown = [l for l in target_locales if l not in LOCALE_LANG]
        if unknown:
            print(f"Unknown locale(s): {', '.join(unknown)}")
            print(f"Supported: {', '.join(LOCALE_LANG.keys())}")
            sys.exit(1)
    else:
        target_locales = list(LOCALE_LANG.keys())

    print(f"Patching 'material' field in spell i18n JSONs")
    print(f"Locales: {', '.join(target_locales)}")
    print(f"Force  : {force}\n")

    for locale in target_locales:
        tgt_lang = LOCALE_LANG[locale]
        print(f"{'='*60}")
        print(f"Locale: {locale} ({tgt_lang})")
        print(f"{'='*60}")
        patch_locale(locale, tgt_lang, force)

    print("Done.")


if __name__ == "__main__":
    main()
