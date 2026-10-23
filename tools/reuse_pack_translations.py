#!/usr/bin/env python3
"""Seed 5.2.1 overlays only from fully identical 5.1 English SRD records."""

import argparse
import json
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SRD = ROOT / "assets" / "data" / "srd"
I18N = ROOT / "assets" / "data" / "i18n"
LOCALES = ("de", "es", "fr", "it", "ja", "ko", "pt", "ru", "tr", "zh")
NAMED_LIST_FILES = (
    "backgrounds.json", "classes.json", "feats.json", "languages.json",
    "magic_items.json", "races.json", "skills.json", "spells.json",
    "tools.json",
)
SUPPORTED_FILES = (*NAMED_LIST_FILES, "feature_usages.json")
TEXT_FIELDS = {
    "backgrounds.json": ("name",),
    "classes.json": ("name", "subclassFeatureName"),
    "feats.json": ("name", "description"),
    "languages.json": ("name",),
    "magic_items.json": ("name", "description"),
    "races.json": ("name",),
    "skills.json": ("name",),
    "spells.json": (
        "name", "description", "higherLevels", "material",
        "castingTime", "range", "duration", "rolls",
    ),
    "tools.json": ("name",),
    "feature_usages.json": ("name", "description"),
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _named_records(records):
    result = {}
    for record in records:
        name = record["name"]
        if name in result:
            raise ValueError(f"Duplicate English name: {name}")
        result[name] = record
    return result


def identical_entry_ids(filename, old_source, new_source):
    """Return new overlay key -> old overlay key for complete SRD matches."""
    if filename in NAMED_LIST_FILES:
        old = _named_records(old_source)
        new = _named_records(new_source)
        return {name: name for name, record in new.items()
                if old.get(name) == record}
    if filename != "feature_usages.json":
        raise ValueError(f"Unsupported file: {filename}")

    old_by_record = defaultdict(list)
    for resource_id, record in old_source["resources"].items():
        signature = json.dumps(record, sort_keys=True, ensure_ascii=False)
        old_by_record[signature].append(resource_id)

    matches = {}
    for resource_id, record in new_source["resources"].items():
        signature = json.dumps(record, sort_keys=True, ensure_ascii=False)
        candidates = old_by_record[signature]
        if len(candidates) == 1:
            matches[resource_id] = candidates[0]
    return matches


def seed_overlay(filename, matches, old_overlay, existing):
    """Add missing translated entries without changing any existing entry."""
    if filename == "feature_usages.json":
        old_entries = old_overlay.get("resources", {})
        current = existing.get("resources", {})
    else:
        old_entries = old_overlay
        current = existing
    if not isinstance(old_entries, dict) or not isinstance(current, dict):
        raise ValueError("Expected overlay entries to be JSON objects")

    additions = {}
    for new_key, old_key in matches.items():
        old_entry = old_entries.get(old_key)
        if new_key in current or not isinstance(old_entry, dict):
            continue
        translated = {
            field: old_entry[field]
            for field in TEXT_FIELDS[filename]
            if field in old_entry
        }
        if translated:
            additions[new_key] = translated
    if filename == "feature_usages.json":
        return {**existing, "resources": {**current, **additions}}, additions
    return {**existing, **additions}, additions


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--file", required=True, choices=SUPPORTED_FILES)
    parser.add_argument("--locale", action="append", choices=LOCALES)
    parser.add_argument("--apply", action="store_true",
                        help="Write only missing entries; otherwise preview")
    args = parser.parse_args()

    old_source = _read_json(SRD / "5.1" / args.file)
    new_source = _read_json(SRD / "5.2.1" / args.file)
    matches = identical_entry_ids(args.file, old_source, new_source)
    print(f"{args.file}: {len(matches)} complete English records match")

    for locale in args.locale or LOCALES:
        old_path = I18N / locale / "5.1" / args.file
        target = I18N / locale / "5.2.1" / args.file
        old_overlay = _read_json(old_path) if old_path.exists() else {}
        existing = _read_json(target) if target.exists() else {}
        result, additions = seed_overlay(args.file, matches, old_overlay, existing)
        print(f"  {locale}: {len(additions)} reusable entries not yet present")
        if args.apply and additions:
            target.parent.mkdir(parents=True, exist_ok=True)
            temporary = target.with_suffix(target.suffix + ".tmp")
            temporary.write_text(
                json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            temporary.replace(target)


if __name__ == "__main__":
    main()
