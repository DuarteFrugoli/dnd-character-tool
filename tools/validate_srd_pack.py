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


def validate_2024_classes(data, errors):
    classes = data.get("classes")
    subclasses = data.get("subclasses")
    if classes is None and subclasses is None:
        return

    expected = {
        "Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk",
        "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard",
    }
    tool_categories = {
        tool.get("category") for tool in data.get("tools", [])
        if isinstance(tool, dict)
    }
    if classes is not None:
        actual = {entry.get("name") for entry in classes if isinstance(entry, dict)}
        if actual != expected:
            errors.append(f"classes: missing or unexpected SRD classes: {sorted(expected ^ actual)}")
        ids = set()
        for index, entry in enumerate(classes):
            if not isinstance(entry, dict):
                continue
            location = f"classes[{index}]"
            class_id = entry.get("id")
            if not isinstance(class_id, str) or not class_id or class_id in ids:
                errors.append(f"{location}: missing or duplicate ID")
            ids.add(class_id)
            if entry.get("subclassLevel") != 3:
                errors.append(f"{location}: subclass must begin at level 3")
            if entry.get("spellcastingType") not in (None, "full", "half", "warlock"):
                errors.append(f"{location}: invalid spellcasting type")
            multiclass = entry.get("multiclassProficiencies")
            if not isinstance(multiclass, dict) or any(
                not isinstance(multiclass.get(key), list)
                for key in ("armor", "weapons", "tools")
            ):
                errors.append(f"{location}: invalid multiclass proficiencies")
            if tool_categories:
                tool_choices = list(entry.get("toolProficiencyChoices", []))
                if isinstance(multiclass, dict):
                    tool_choices += multiclass.get("toolChoices", [])
                for tool_choice in tool_choices:
                    categories = tool_choice.get("categories", [tool_choice.get("category")])
                    if not isinstance(categories, list) or not set(categories) <= tool_categories:
                        errors.append(f"{location}: unknown tool choice category")
            choices = entry.get("equipmentChoices")
            if not isinstance(choices, list) or len(choices) < 2:
                errors.append(f"{location}: missing equipment choices")
                continue
            choice_ids = set()
            for choice in choices:
                if not isinstance(choice, dict):
                    errors.append(f"{location}: invalid equipment choice")
                    continue
                choice_id = choice.get("id")
                if choice_id in choice_ids or not isinstance(choice_id, str):
                    errors.append(f"{location}: duplicate or missing equipment choice ID")
                choice_ids.add(choice_id)
                if not isinstance(choice.get("gp"), int) or choice["gp"] < 0:
                    errors.append(f"{location}: invalid starting gold")
                items = choice.get("items")
                if not isinstance(items, list) or any(
                    not isinstance(item, dict)
                    or not isinstance(item.get("quantity"), int)
                    or item["quantity"] < 1
                    or sum(key in item for key in ("name", "category", "selection")) != 1
                    for item in items
                ):
                    errors.append(f"{location}: invalid starting equipment items")
                elif tool_categories:
                    for item in items:
                        if item.get("category") and item["category"] not in tool_categories:
                            errors.append(f"{location}: unknown starting equipment category")

    if subclasses is not None:
        if set(subclasses) != expected:
            errors.append(f"subclasses: missing or unexpected SRD classes: {sorted(expected ^ set(subclasses))}")
        subclass_ids = set()
        for class_name, entries in subclasses.items():
            if not isinstance(entries, list) or len(entries) != 1:
                errors.append(f"subclasses.{class_name}: expected one SRD subclass")
                continue
            entry = entries[0]
            if not isinstance(entry, dict):
                continue
            subclass_id = entry.get("id")
            if not isinstance(subclass_id, str) or not subclass_id or subclass_id in subclass_ids:
                errors.append(f"subclasses.{class_name}: missing or duplicate ID")
            subclass_ids.add(subclass_id)
            if not isinstance(entry.get("description"), str) or not entry["description"].strip():
                errors.append(f"subclasses.{class_name}: missing description")


def validate_2024_spells(data, errors):
    spells = data.get("spells")
    if spells is None:
        return
    expected_counts = {0: 27, 1: 57, 2: 57, 3: 42, 4: 34, 5: 38, 6: 31, 7: 20, 8: 17, 9: 16}
    for level, expected in expected_counts.items():
        count = sum(
            spell.get("level") == level for spell in spells if isinstance(spell, dict)
        )
        if count != expected:
            errors.append(
                f"spells: expected {expected} SRD level {level} spells, found {count}"
            )
    classes = {
        "bard", "cleric", "druid", "paladin", "ranger",
        "sorcerer", "warlock", "wizard",
    }
    for index, spell in enumerate(spells):
        if not isinstance(spell, dict):
            errors.append(f"spells[{index}]: expected object")
            continue
        location = f"spells[{index}]"
        for field in ("school", "castingTime", "range", "duration", "description"):
            if not isinstance(spell.get(field), str) or not spell[field].strip():
                errors.append(f"{location}: missing {field}")
        for field in ("ritual", "materialConsumed", "concentration"):
            if not isinstance(spell.get(field), bool):
                errors.append(f"{location}: invalid {field}")
        components = spell.get("components")
        if (
            not isinstance(components, list)
            or not components
            or len(components) != len(set(components))
            or not set(components) <= {"V", "S", "M"}
            or ("M" in components) != isinstance(spell.get("material"), str)
        ):
            errors.append(f"{location}: invalid components or material")
        spell_classes = spell.get("classes")
        if not isinstance(spell_classes, list) or not spell_classes or not set(spell_classes) <= classes:
            errors.append(f"{location}: invalid class list")
        if spell.get("castingTimeType") not in (
            "action", "bonus_action", "reaction", "minute", "hour"
        ):
            errors.append(f"{location}: invalid casting time type")
        rolls = spell.get("rolls", [])
        if not isinstance(rolls, list) or any(
            not isinstance(roll, dict)
            or not isinstance(roll.get("id"), str)
            or roll.get("kind") not in ("spell_attack", "damage")
            for roll in rolls
        ):
            errors.append(f"{location}: invalid rolls")


def validate_2024_origins(data, errors):
    feats = data.get("feats")
    feat_ids = set()
    feat_names = set()
    feats_by_id = {}
    if feats is not None:
        for index, feat in enumerate(feats):
            if not isinstance(feat, dict):
                continue
            feat_id = feat.get("id")
            if not isinstance(feat_id, str) or not feat_id:
                errors.append(f"feats[{index}]: missing ID")
            elif feat_id in feat_ids:
                errors.append(f"feats: duplicate ID {feat_id!r}")
            else:
                feat_ids.add(feat_id)
                feats_by_id[feat_id] = feat
            if feat.get("category") not in ("origin", "general", "fighting_style", "epic_boon"):
                errors.append(f"feats[{index}]: invalid category")
            if not isinstance(feat.get("description"), str) or not feat["description"].strip():
                errors.append(f"feats[{index}]: missing description")
            if isinstance(feat.get("name"), str):
                feat_names.add(feat["name"])

    backgrounds = data.get("backgrounds")
    if backgrounds is not None:
        background_ids = set()
        known_items = set()
        if "equipment" in data and "tools" in data:
            known_items = {
                entry["name"]
                for section in ("weapons", "armor", "gear")
                for entry in data["equipment"].get(section, [])
            } | {tool["name"] for tool in data["tools"]}
        ability_ids = {
            "strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"
        }
        for index, background in enumerate(backgrounds):
            if not isinstance(background, dict):
                continue
            location = f"backgrounds[{index}]"
            background_id = background.get("id")
            if not isinstance(background_id, str) or not background_id:
                errors.append(f"{location}: missing ID")
            elif background_id in background_ids:
                errors.append(f"backgrounds: duplicate ID {background_id!r}")
            else:
                background_ids.add(background_id)

            scores = background.get("abilityScoreOptions")
            if (
                not isinstance(scores, list)
                or len(scores) != 3
                or any(not isinstance(score, str) for score in scores)
                or set(scores) - ability_ids
                or len(set(scores)) != 3
            ):
                errors.append(f"{location}: expected three distinct ability scores")
            skills = background.get("skillProficiencies")
            if (
                not isinstance(skills, list)
                or len(skills) != 2
                or not all(isinstance(skill, str) and skill for skill in skills)
            ):
                errors.append(f"{location}: expected two skill proficiencies")
            elif "skills" in data:
                known_skills = {skill["name"].lower() for skill in data["skills"]}
                if set(skills) - known_skills:
                    errors.append(f"{location}: unknown skill proficiency")
            tools = background.get("toolProficiencies")
            tool_choices = background.get("toolProficiencyChoices", [])
            if (
                not isinstance(tools, list)
                or not isinstance(tool_choices, list)
                or len(tools) + len(tool_choices) != 1
            ):
                errors.append(f"{location}: expected one tool proficiency or choice")
            elif "tools" in data:
                known_tools = {tool["name"] for tool in data["tools"]}
                known_categories = {tool["category"] for tool in data["tools"]}
                if set(tools) - known_tools:
                    errors.append(f"{location}: unknown tool proficiency")
                if any(choice.get("category") not in known_categories for choice in tool_choices):
                    errors.append(f"{location}: unknown tool choice category")

            feat_ref = background.get("originFeatRef")
            prefix = "srd_5_2_1/feat/"
            if not isinstance(feat_ref, str) or not feat_ref.startswith(prefix):
                errors.append(f"{location}: invalid origin feat reference")
            elif feats is not None and feat_ref[len(prefix):] not in feat_ids:
                errors.append(f"{location}: unknown origin feat {feat_ref!r}")
            fixed_choices = background.get("originFeatChoices", {})
            if not isinstance(fixed_choices, dict):
                errors.append(f"{location}: invalid origin feat choices")
            elif isinstance(feat_ref, str) and "feature_choices" in data:
                feat = feats_by_id.get(feat_ref.removeprefix(prefix))
                choice_catalog = data["feature_choices"]
                feat_choices = choice_catalog.get("feats", {}).get(
                    feat.get("name") if feat else None, {}
                ).get("choices", [])
                for choice_id, option_id in fixed_choices.items():
                    definition = next(
                        (choice for choice in feat_choices if choice.get("id") == choice_id),
                        None,
                    )
                    source_name = definition.get("optionsSource") if definition else None
                    options = choice_catalog.get("optionSources", {}).get(source_name, [])
                    if option_id not in {option.get("id") for option in options}:
                        errors.append(
                            f"{location}: invalid fixed feat choice {choice_id}={option_id}"
                        )

            equipment = background.get("equipmentChoices")
            if (
                not isinstance(equipment, list)
                or len(equipment) != 2
                or not all(isinstance(option, dict) for option in equipment)
                or {option.get("id") for option in equipment} != {"a", "b"}
            ):
                errors.append(f"{location}: expected equipment options a and b")
                continue
            for option in equipment:
                if not isinstance(option.get("gp"), int) or option["gp"] < 0:
                    errors.append(f"{location}: invalid starting gold")
                items = option.get("items")
                if not isinstance(items, list):
                    errors.append(f"{location}: missing equipment items")
                    continue
                for item in items:
                    if (
                        not isinstance(item, dict)
                        or not isinstance(item.get("name"), str)
                        or not isinstance(item.get("quantity"), int)
                        or item["quantity"] < 1
                    ):
                        errors.append(f"{location}: invalid equipment item")
                    elif known_items and not item.get("choiceFrom"):
                        if item["name"] not in known_items:
                            errors.append(f"{location}: unknown starting item {item['name']!r}")

    races = data.get("races")
    traits = data.get("race_traits")
    if races is not None:
        race_ids = set()
        for index, race in enumerate(races):
            location = f"races[{index}]"
            race_id = race.get("id")
            if not isinstance(race_id, str) or not race_id or race_id in race_ids:
                errors.append(f"{location}: missing or duplicate species ID")
            race_ids.add(race_id)
            if race.get("creatureType") != "Humanoid" or race.get("speed", 0) <= 0:
                errors.append(f"{location}: invalid creature type or speed")
            if not race.get("sizeOptions") or set(race["sizeOptions"]) - {"Small", "Medium"}:
                errors.append(f"{location}: invalid size options")
            if traits is not None:
                referenced = race.get("traits", []) + [
                    lineage["trait"] for lineage in race.get("lineages", []) if "trait" in lineage
                ]
                if set(referenced) - set(traits):
                    errors.append(f"{location}: unknown racial trait")
            for key in ("lineages", "ancestryOptions"):
                options = race.get(key, [])
                ids = [option.get("id") for option in options]
                if len(ids) != len(set(ids)):
                    errors.append(f"{location}: duplicate {key} ID")

    for filename in ("feature_choices", "feature_usages"):
        catalog = data.get(filename)
        if catalog is not None and feats is not None:
            for feat_name in catalog.get("feats", {}):
                if feat_name not in feat_names:
                    errors.append(f"{filename}: unknown feat {feat_name!r}")

    choices = data.get("feature_choices")
    usages = data.get("feature_usages")
    if choices is not None and usages is not None:
        for feat_name, usage in usages.get("feats", {}).items():
            instance_choice = usage.get("instanceKeyFromChoice")
            if instance_choice is None:
                continue
            feat_choices = choices.get("feats", {}).get(feat_name, {}).get("choices", [])
            if instance_choice not in {choice.get("id") for choice in feat_choices}:
                errors.append(
                    f"feature_usages.feats.{feat_name}: unknown instance choice {instance_choice!r}"
                )


def validate(pack, only=None):
    source = ROOT / "assets" / "data" / "srd" / pack
    errors = []
    data = {}
    for filename, expected_type in FILES.items():
        if only is not None and filename not in only:
            continue
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

    if "equipment" in data:
        equipment = data["equipment"]
        for section in ("weapons", "armor", "gear"):
            entries = equipment.get(section)
            if not isinstance(entries, list):
                errors.append(f"equipment.{section}: missing list")
            else:
                names(entries, f"equipment.{section}", errors)
        if pack == "5.2.1":
            masteries = equipment.get("weaponMasteries", {})
            if not isinstance(masteries, dict):
                errors.append("equipment.weaponMasteries: expected object")
            else:
                for index, weapon in enumerate(equipment.get("weapons", [])):
                    if weapon.get("mastery") not in masteries:
                        errors.append(f"equipment.weapons[{index}]: unknown mastery")
                    ammo = weapon.get("ammunition")
                    if ammo is not None and ammo not in {
                        item.get("name") for item in equipment.get("gear", [])
                    }:
                        errors.append(f"equipment.weapons[{index}]: unknown ammunition")

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

    if pack == "5.2.1":
        manifest_path = source / "manifest.json"
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"), object_pairs_hook=unique_pairs)
        except (OSError, UnicodeError, ValueError) as exc:
            errors.append(f"{manifest_path}: {exc}")
        else:
            if not isinstance(manifest, dict) or manifest.get("id") != "srd_5_2_1" or manifest.get("license") != "CC-BY-4.0":
                errors.append("manifest.json: invalid pack ID or license")
            else:
                complete = manifest.get("completeCatalogs", [])
                pending = manifest.get("pendingCatalogs", [])
                if (
                    not isinstance(complete, list)
                    or not isinstance(pending, list)
                    or set(complete) & set(pending)
                    or set(complete) | set(pending) != set(FILES)
                    or len(complete) + len(pending) != len(FILES)
                ):
                    errors.append("manifest.json: catalog status must partition all SRD files")
                else:
                    for filename in complete:
                        if not (source / f"{filename}.json").is_file():
                            errors.append(f"manifest.json: complete catalog {filename!r} is missing")
                    if not pending and manifest.get("status") != "complete":
                        errors.append("manifest.json: complete pack has unfinished status")
                    if pending and manifest.get("status") != "in_progress":
                        errors.append("manifest.json: pending catalogs require in_progress status")
        validate_2024_origins(data, errors)
        validate_2024_classes(data, errors)
        validate_2024_spells(data, errors)

    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", choices=("5.1", "5.2.1"))
    parser.add_argument(
        "--only",
        nargs="+",
        choices=tuple(FILES),
        help="validate selected catalogs while a pack is in progress",
    )
    args = parser.parse_args()
    errors = validate(args.pack, only=set(args.only) if args.only else None)
    if errors:
        for error in errors:
            print(error)
        raise SystemExit(f"SRD {args.pack}: {len(errors)} integrity issue(s)")
    count = len(args.only) if args.only else len(FILES)
    print(f"SRD {args.pack}: {count} English JSON files passed integrity checks")


if __name__ == "__main__":
    main()
