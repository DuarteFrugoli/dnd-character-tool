"""Check translated SRD overlays against their English source catalogs.

Examples:
  python tools/check_srd_i18n.py --pack 5.1 --file magic_items.json
  python tools/check_srd_i18n.py --pack 5.2.1
  python tools/check_srd_i18n.py --pack 5.2.1 pt es --file spells.json
"""

import argparse
import json

import translate_i18n as translation


def missing_paths(source, overlay, path=()):
    if isinstance(source, dict):
        existing = overlay if isinstance(overlay, dict) else {}
        for key, value in source.items():
            if key in translation.TECHNICAL_FIELDS:
                continue
            yield from missing_paths(value, existing.get(key), (*path, key))
    elif isinstance(source, list):
        existing = overlay if isinstance(overlay, list) else []
        for index, value in enumerate(source):
            yield from missing_paths(
                value, existing[index] if index < len(existing) else None,
                (*path, str(index)),
            )
    elif isinstance(source, str) and source.strip():
        if not isinstance(overlay, str) or not overlay.strip():
            yield path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("locales", nargs="*", choices=tuple(translation.LOCALE_LANG))
    parser.add_argument("--pack", choices=("5.1", "5.2.1"), required=True)
    parser.add_argument("--file", action="append", choices=tuple(translation.EXTRACTORS))
    args = parser.parse_args()
    translation.SRD_DIR = translation.ROOT / "assets" / "data" / "srd" / args.pack
    files = args.file or sorted(translation.EXTRACTORS)
    locales = args.locales or list(translation.LOCALE_LANG)
    missing_total = 0
    for filename in files:
        expected = translation.EXTRACTORS[filename]()
        for locale in locales:
            path = translation.I18N_DIR / locale / args.pack / filename
            try:
                overlay = json.loads(path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError, ValueError):
                overlay = {}
            missing = list(missing_paths(expected, overlay))
            missing_total += len(missing)
            print(f"{args.pack} {locale} {filename}: {len(missing)} missing text fields")
            for parts in missing[:5]:
                print("  " + "/".join(parts))
    print(f"Total missing text fields: {missing_total}")
    return int(missing_total > 0)


if __name__ == "__main__":
    raise SystemExit(main())
