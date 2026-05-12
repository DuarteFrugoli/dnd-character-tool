#!/usr/bin/env python3
"""Add missing ARB keys to generated locale files by translating from English."""
import json
import time
import random
from pathlib import Path

try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("ERROR: pip install deep-translator")
    raise SystemExit(1)

L10N = Path(__file__).resolve().parent.parent / "lib" / "l10n"
LOCALE_LANG = {"de": "de", "it": "it", "ja": "ja", "ko": "ko", "ru": "ru", "zh": "zh-CN"}

src = json.loads((L10N / "app_en.arb").read_text(encoding="utf-8"))


def translate(text: str, lang: str) -> str:
    for attempt in range(3):
        try:
            result = GoogleTranslator(source="en", target=lang).translate(text)
            time.sleep(0.3 + random.uniform(0, 0.15))
            return result if result else text
        except Exception:
            if attempt == 2:
                return text
            time.sleep(1)


for locale, lang in LOCALE_LANG.items():
    dst_path = L10N / f"app_{locale}.arb"
    dst = json.loads(dst_path.read_text(encoding="utf-8-sig"))

    missing = {
        k: v
        for k, v in src.items()
        if not k.startswith("@") and k != "@@locale" and k not in dst
    }

    if not missing:
        print(f"{locale}: nothing to do.")
        continue

    print(f"{locale}: translating {len(missing)} key(s)...")
    for key, value in missing.items():
        translated = translate(value, lang)
        dst[key] = translated
        print(f"  {key}: {translated[:60]}")

    dst_path.write_text(
        json.dumps(dst, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"  -> saved {dst_path.name}\n")

print("Done!")
