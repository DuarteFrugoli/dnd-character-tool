#!/usr/bin/env python3
"""Validate an English SRD pack before generating translated overlays."""

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
FILES = {
    "backgrounds": list,
    "class_features": list,
    "classes": list,
    "conditions": list,
    "equipment": dict,
    "feats": list,
    "feature_choices": dict,
    "feature_usages": dict,
    "languages": list,
    "magic_items": list,
    "race_traits": dict,
    "races": list,
    "skills": list,
    "spells": list,
    "subclass_features": list,
    "subclasses": dict,
    "tools": list,
}


def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def names(entries, location, errors, *, by_level=False):
    found = set()
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict) or not isinstance(entry.get("name"), str) or not entry["name"].strip():
            errors.append(f"{location}[{index}]: missing name")
            continue
        name = entry["name"]
        key = (name, entry.get("level")) if by_level else name
        if key in found:
            errors.append(f"{location}: duplicate name/level {key!r}")
        found.add(key)
    return found


def validate_choice_refs(node, sources, location, errors):
    if isinstance(node, list):
        for index, child in enumerate(node):
            validate_choice_refs(child, sources, f"{location}[{index}]", errors)
    elif isinstance(node, dict):
        source = node.get("optionsSource")
        if source is not None and source not in sources:
            errors.append(f"{location}: unknown optionsSource {source!r}")
        choices = node.get("choices")
        if isinstance(choices, list):
            ids = [choice.get("id") for choice in choices if isinstance(choice, dict)]
            if len(ids) != len(set(ids)):
                errors.append(f"{location}: duplicate choice ID")
        for key, child in node.items():
            validate_choice_refs(child, sources, f"{location}.{key}", errors)


def validate(pack):
    source = ROOT / "assets" / "data" / "srd" / pack
    errors = []
    data = {}
    for filename, expected_type in FILES.items():
        path = source / f"{filename}.json"
        if not path.is_file():
            errors.append(f"{path}: missing file")
            continue
        try:
            value = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_pairs)
        except (OSError, UnicodeError, ValueError) as exc:
            errors.append(f"{path}: {exc}")
            continue
        if not isinstance(value, expected_type):
            errors.append(f"{path}: expected {expected_type.__name__}")
            continue
        if not value:
            errors.append(f"{path}: empty catalog")
        data[filename] = value

    for filename, value in data.items():
        if isinstance(value, list) and filename not in ("class_features", "subclass_features", "classes"):
            names(value, filename, errors)

    classes = names(data.get("classes", []), "classes", errors) if "classes" in data else set()
    if classes:
        subclasses = data.get("subclasses", {})
        for class_name, entries in subclasses.items():
            if class_name not in classes:
                errors.append(f"subclasses: unknown class {class_name!r}")
            if not isinstance(entries, list):
                errors.append(f"subclasses.{class_name}: expected list")
                continue
            names(entries, f"subclasses.{class_name}", errors)
        for filename in ("class_features", "subclass_features"):
            for index, row in enumerate(data.get(filename, [])):
                if not isinstance(row, dict):
                    errors.append(f"{filename}[{index}]: expected object")
                    continue
                class_name = row.get("class")
                if class_name not in classes:
                    errors.append(f"{filename}[{index}]: unknown class {class_name!r}")
                if filename == "subclass_features" and isinstance(subclasses.get(class_name), list):
                    known = {entry.get("name") for entry in subclasses[class_name] if isinstance(entry, dict)}
                    if row.get("subclass") not in known:
                        errors.append(f"{filename}[{index}]: unknown subclass {row.get('subclass')!r}")
                if not isinstance(row.get("features"), list):
                    errors.append(f"{filename}[{index}]: missing features list")
                else:
                    names(row["features"], f"{filename}[{index}].features", errors, by_level=True)

    equipment = data.get("equipment", {})
    for section in ("weapons", "armor", "gear"):
        entries = equipment.get(section)
        if not isinstance(entries, list):
            errors.append(f"equipment.{section}: missing list")
        else:
            names(entries, f"equipment.{section}", errors)

    choices = data.get("feature_choices", {})
    choice_sources = choices.get("optionSources", {})
    for source_name, options in choice_sources.items():
        if not isinstance(options, list):
            errors.append(f"feature_choices.optionSources.{source_name}: expected list")
            continue
        seen = set()
        for option in options:
            option_id = option.get("id") if isinstance(option, dict) else None
            if not isinstance(option_id, str) or not option_id:
                errors.append(f"feature_choices.optionSources.{source_name}: missing option ID")
            elif option_id in seen:
                errors.append(f"feature_choices.optionSources.{source_name}: duplicate ID {option_id!r}")
            seen.add(option_id)

    validate_choice_refs(choices, choice_sources, "feature_choices", errors)

    usages = data.get("feature_usages", {})
    resource_ids = usages.get("resources", {})

    def validate_resource_refs(node, location):
        if isinstance(node, list):
            for index, child in enumerate(node):
                validate_resource_refs(child, f"{location}[{index}]")
        elif isinstance(node, dict):
            resource_id = node.get("resourceId")
            if resource_id is not None and resource_id not in resource_ids:
                errors.append(f"{location}: unknown resourceId {resource_id!r}")
            for key, child in node.items():
                validate_resource_refs(child, f"{location}.{key}")

    validate_resource_refs(usages, "feature_usages")

    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", choices=("5.1", "5.2.1"))
    args = parser.parse_args()
    errors = validate(args.pack)
    if errors:
        for error in errors:
            print(error)
        raise SystemExit(f"SRD {args.pack}: {len(errors)} integrity issue(s)")
    print(f"SRD {args.pack}: {len(FILES)} English JSON files passed integrity checks")


if __name__ == "__main__":
    main()
