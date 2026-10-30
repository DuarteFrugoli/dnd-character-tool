#!/usr/bin/env python3
"""Validate the structure and references of an English SRD pack."""

import argparse
import json
import re
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
    "monsters": list,
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
            progression = entry.get("progression")
            if not isinstance(progression, list) or len(progression) != 20:
                errors.append(f"{location}: expected 20 progression levels")
            else:
                for level, row in enumerate(progression, 1):
                    row_location = f"{location}.progression[{level - 1}]"
                    if not isinstance(row, dict) or row.get("level") != level:
                        errors.append(f"{row_location}: invalid level")
                        continue
                    if row.get("proficiencyBonus") != 2 + (level - 1) // 4:
                        errors.append(f"{row_location}: invalid proficiency bonus")
                    if not isinstance(row.get("features"), list) or any(
                        not isinstance(name, str) or not name.strip() or name in ("\u2014", "-")
                        for name in row["features"]
                    ):
                        errors.append(f"{row_location}: missing class features")
                    if entry.get("name") in {"Barbarian", "Fighter", "Paladin", "Ranger", "Rogue"} and (
                        type(row.get("weaponMasteryCount")) is not int or row["weaponMasteryCount"] < 2
                    ):
                        errors.append(f"{row_location}: missing weapon mastery count")
                    if entry.get("name") == "Warlock" and (
                        type(row.get("eldritchInvocationsKnown")) is not int
                        or row["eldritchInvocationsKnown"] < 1
                    ):
                        errors.append(f"{row_location}: missing invocation count")
                    slots = row.get("spellSlots")
                    slot_count = {"full": 9, "half": 5}.get(entry.get("spellcastingType"))
                    if slot_count is not None and (
                        not isinstance(slots, list) or len(slots) != slot_count
                        or any(type(count) is not int or count < 0 for count in slots)
                    ):
                        errors.append(f"{row_location}: invalid spell slots")
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


def validate_2024_features(data, errors):
    expected_counts = {
        "class_features": {
            "Barbarian": 20, "Bard": 12, "Cleric": 11, "Druid": 13,
            "Fighter": 15, "Monk": 22, "Paladin": 17, "Ranger": 17,
            "Rogue": 18, "Sorcerer": 10, "Warlock": 9, "Wizard": 10,
        },
        "subclass_features": {
            "Barbarian": 4, "Bard": 4, "Cleric": 5, "Druid": 5,
            "Fighter": 6, "Monk": 4, "Paladin": 5, "Ranger": 5,
            "Rogue": 5, "Sorcerer": 5, "Warlock": 5, "Wizard": 5,
        },
    }
    for filename, counts in expected_counts.items():
        rows = data.get(filename)
        if rows is None:
            continue
        found = set()
        for index, row in enumerate(rows):
            if not isinstance(row, dict):
                continue
            location = f"{filename}[{index}]"
            class_name = row.get("class")
            if not isinstance(class_name, str):
                errors.append(f"{location}: missing class")
                continue
            if class_name in found:
                errors.append(f"{location}: duplicate class {class_name!r}")
            found.add(class_name)
            features = row.get("features")
            if not isinstance(features, list):
                continue
            if class_name in counts and len(features) != counts[class_name]:
                errors.append(
                    f"{location}: expected {counts[class_name]} features, found {len(features)}"
                )
            for feature_index, feature in enumerate(features):
                feature_location = f"{location}.features[{feature_index}]"
                if not isinstance(feature, dict):
                    errors.append(f"{feature_location}: expected object")
                    continue
                if not isinstance(feature.get("name"), str) or not feature["name"].strip():
                    errors.append(f"{feature_location}: missing name")
                if type(feature.get("level")) is not int or not 1 <= feature["level"] <= 20:
                    errors.append(f"{feature_location}: invalid level")
                if feature.get("type") not in ("active", "passive", "subclass", "asi", "epic_boon"):
                    errors.append(f"{feature_location}: invalid type")
                if filename == "class_features" and (
                    (feature.get("name") == "Epic Boon")
                    != (feature.get("level") == 19 and feature.get("type") == "epic_boon")
                ):
                    errors.append(f"{feature_location}: invalid Epic Boon milestone")
                if not isinstance(feature.get("description"), str) or not feature["description"].strip():
                    errors.append(f"{feature_location}: missing description")
        if found != set(counts):
            errors.append(f"{filename}: missing or unexpected SRD classes: {sorted(set(counts) ^ found)}")

    if "classes" in data and "class_features" in data:
        classes_by_name = {
            entry["name"]: entry for entry in data["classes"]
            if isinstance(entry, dict) and isinstance(entry.get("name"), str)
        }
        for row in data["class_features"]:
            if not isinstance(row, dict) or row.get("class") not in classes_by_name:
                continue
            marker = classes_by_name[row["class"]].get("subclassFeatureName")
            if not any(
                isinstance(feature, dict) and feature.get("name") == marker
                and feature.get("level") == 3 and feature.get("type") == "subclass"
                for feature in (row.get("features") or [])
            ):
                errors.append(f"class_features.{row['class']}: missing level 3 subclass marker")

    if "subclasses" in data and "subclass_features" in data:
        for row in data["subclass_features"]:
            if not isinstance(row, dict):
                continue
            entries = data["subclasses"].get(row.get("class"), [])
            if not isinstance(entries, list) or row.get("subclass") not in {
                entry.get("name") for entry in entries if isinstance(entry, dict)
            }:
                errors.append(f"subclass_features.{row.get('class')}: unknown subclass")
            if not any(
                isinstance(feature, dict) and feature.get("level") == 3
                for feature in (row.get("features") or [])
            ):
                errors.append(f"subclass_features.{row.get('class')}: missing level 3 feature")


def validate_2024_feature_catalogs(data, errors):
    class_rows = {
        row["class"]: {feature["name"] for feature in row["features"]}
        for row in data.get("class_features", [])
        if isinstance(row, dict) and isinstance(row.get("features"), list)
    }
    subclass_rows = {
        (row["class"], row["subclass"]): {
            feature["name"] for feature in row["features"]
        }
        for row in data.get("subclass_features", [])
        if isinstance(row, dict) and isinstance(row.get("features"), list)
    }
    for filename in ("feature_choices", "feature_usages"):
        catalog = data.get(filename)
        if catalog is None:
            continue
        if class_rows:
            for class_name, definitions in catalog.get("classFeatures", {}).items():
                for feature_name in definitions:
                    if feature_name not in class_rows.get(class_name, set()):
                        errors.append(
                            f"{filename}.classFeatures.{class_name}: unknown feature {feature_name!r}"
                        )
        if subclass_rows:
            for class_name, subclasses in catalog.get("subclassFeatures", {}).items():
                for subclass_name, definitions in subclasses.items():
                    for feature_name in definitions:
                        if feature_name not in subclass_rows.get((class_name, subclass_name), set()):
                            errors.append(
                                f"{filename}.subclassFeatures.{class_name}.{subclass_name}: "
                                f"unknown feature {feature_name!r}"
                            )
        if "race_traits" in data:
            for trait_name in catalog.get("raceTraits", {}):
                if trait_name not in data["race_traits"]:
                    errors.append(f"{filename}.raceTraits: unknown trait {trait_name!r}")

    choices = data.get("feature_choices", {})
    sources = choices.get("optionSources", {})
    invocations = sources.get("eldritch_invocations_2024", [])
    invocation_ids = {option.get("id") for option in invocations if isinstance(option, dict)}
    if "feature_choices" in data and (len(invocations) != 28 or len(invocation_ids) != 28):
        errors.append("feature_choices: expected 28 distinct Warlock invocations")
    for option in invocations:
        if not isinstance(option, dict):
            errors.append("feature_choices: invalid invocation")
            continue
        if any(required not in invocation_ids for required in option.get("requiresInvocations", [])):
            errors.append(f"feature_choices: unknown prerequisite for {option.get('id')!r}")
        if option.get("repeatableWithDifferentTarget") and not option.get("target"):
            errors.append(f"feature_choices: repeatable invocation without target {option.get('id')!r}")
    for class_name in (("Barbarian", "Fighter", "Paladin", "Ranger", "Rogue") if "feature_choices" in data else ()):
        mastery = choices.get("classFeatures", {}).get(class_name, {}).get("Weapon Mastery", {})
        requirements = mastery.get("choices", [])
        if len(requirements) != 1 or requirements[0].get("optionsSource") not in sources:
            errors.append(f"feature_choices: missing {class_name} weapon mastery")
    invocations_choice = choices.get("classFeatures", {}).get("Warlock", {}).get("Eldritch Invocations", {})
    if "feature_choices" in data and len(invocations_choice.get("choices", [])) != 3:
        errors.append("feature_choices: missing Warlock invocations choice")
    classes_by_name = {entry["name"]: entry for entry in data.get("classes", []) if isinstance(entry, dict)}
    for class_name, feature_name, column in [
        *((name, "Weapon Mastery", "weaponMasteryCount") for name in
          ("Barbarian", "Fighter", "Paladin", "Ranger", "Rogue")),
        ("Warlock", "Eldritch Invocations", "eldritchInvocationsKnown"),
    ]:
        entry = classes_by_name.get(class_name)
        requirements = choices.get("classFeatures", {}).get(class_name, {}).get(feature_name, {}).get("choices", [])
        if entry is None or not requirements:
            continue
        increases = requirements[0].get("countByLevel", {})
        for row in entry.get("progression", []):
            if not isinstance(row, dict):
                continue
            expected = row.get(column)
            actual = sum(count for threshold, count in increases.items() if int(threshold) <= row["level"])
            if expected != actual:
                errors.append(f"feature_choices: {class_name} {feature_name} count disagrees at level {row['level']}")
    for section in ("classFeatures", "subclassFeatures", "raceTraits", "feats"):
        def check_definitions(node, location):
            if not isinstance(node, dict):
                return
            if "choices" not in node:
                for key, child in node.items():
                    check_definitions(child, f"{location}.{key}")
                return
            requirements = node["choices"]
            by_id = {item.get("id"): item for item in requirements if isinstance(item, dict)}
            for requirement in requirements:
                if not isinstance(requirement, dict):
                    continue
                parent_id = requirement.get("whenChoiceId")
                if parent_id is not None:
                    parent = by_id.get(parent_id)
                    if parent is None or parent is requirement:
                        errors.append(f"{location}: invalid conditional choice {parent_id!r}")
                    else:
                        options = parent.get("options", sources.get(parent.get("optionsSource"), []))
                        if requirement.get("whenOptionId") not in {
                            option.get("id") for option in options if isinstance(option, dict)
                        }:
                            errors.append(f"{location}: unknown conditional option")
                spell_classes = requirement.get("spellClasses", [])
                if not isinstance(spell_classes, list) or any(
                    not isinstance(name, str) for name in spell_classes
                ) or set(spell_classes) - {
                    "bard", "cleric", "druid", "paladin", "ranger",
                    "sorcerer", "warlock", "wizard",
                }:
                    errors.append(f"{location}: invalid spellClasses")
                if requirement.get("featCategory") not in (
                    None, "origin", "general", "fighting_style", "epic_boon"
                ):
                    errors.append(f"{location}: invalid featCategory")
                for field in ("countByLevel", "maxSpellLevelByLevel"):
                    tiers = requirement.get(field, {})
                    if not isinstance(tiers, dict) or any(
                        not str(level).isdigit() or int(level) < 1
                        or type(amount) is not int or amount < 0
                        for level, amount in tiers.items()
                    ):
                        errors.append(f"{location}: invalid {field}")

        check_definitions(choices.get(section, {}), f"feature_choices.{section}")

    usages = data.get("feature_usages", {})
    for feature_name in (("Mystic Arcanum", "Signature Spells") if "feature_usages" in data else ()):
        owner = "Warlock" if feature_name == "Mystic Arcanum" else "Wizard"
        if not usages.get("classFeatures", {}).get(owner, {}).get(feature_name, {}).get("additionalResources"):
            errors.append(f"feature_usages: missing independent uses for {feature_name}")
    if "feature_usages" in data and not usages.get("subclassFeatures", {}).get("Druid", {}).get("Circle of the Land", {}).get("Natural Recovery", {}).get("additionalResources"):
        errors.append("feature_usages: missing independent Natural Recovery uses")
    supported_recharges = {
        "short_rest", "short_or_long_rest", "short_rest_one",
        "long_rest", "bardic_inspiration_recharge",
    }
    supported_formulas = {
        "charisma_modifier_min_1", "wisdom_modifier_min_1",
        "fighter_action_surge_uses", "fighter_indomitable_uses",
        "monk_level", "sorcerer_level", "paladin_level_x5",
        "proficiency_bonus",
    }
    for resource_id, resource in usages.get("resources", {}).items():
        if resource.get("recharge") not in supported_recharges:
            errors.append(f"feature_usages.resources.{resource_id}: unsupported recharge")
        maximum = str(resource.get("max", ""))
        if not maximum.isdigit() and maximum not in supported_formulas:
            errors.append(f"feature_usages.resources.{resource_id}: unsupported max formula")
        tiers = resource.get("maxByLevel", {})
        if not isinstance(tiers, dict) or any(
            not str(level).isdigit() or int(level) < 1
            or type(amount) is not int or amount < 0
            for level, amount in tiers.items()
        ):
            errors.append(f"feature_usages.resources.{resource_id}: invalid maxByLevel")


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


MONSTER_SIZES = {"tiny", "small", "medium", "large", "huge", "gargantuan"}
MONSTER_ABILITIES = ("strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma")
MONSTER_SKILLS = {
    "acrobatics", "animal handling", "arcana", "athletics", "deception", "history", "insight",
    "intimidation", "investigation", "medicine", "nature", "perception", "performance",
    "persuasion", "religion", "sleight of hand", "stealth", "survival",
}
MONSTER_DAMAGE_TYPES = {
    "acid", "bludgeoning", "cold", "fire", "force", "lightning", "necrotic", "piercing",
    "poison", "psychic", "radiant", "slashing", "thunder",
}
MONSTER_SPEEDS = {"walk", "burrow", "climb", "fly", "swim"}
MONSTER_SENSES = {"blindsight", "darkvision", "tremorsense", "truesight"}
MONSTER_SECTIONS = ("traits", "actions", "bonusActions", "reactions", "legendaryActions")
CHALLENGE_RATINGS = ["0", "1/8", "1/4", "1/2"] + [str(value) for value in range(1, 31)]


def dice_average(formula):
    """Average of a formula such as `2d6+3`, or None when it is not one."""
    if not isinstance(formula, str) or not re.fullmatch(r"\d+(?:d\d+)?(?:[+-]\d+(?:d\d+)?)*", formula):
        return None
    total = 0.0
    for sign, count, sides, flat in re.findall(r"([+-]?)(?:(\d+)d(\d+)|(\d+))", formula):
        value = int(count) * (int(sides) + 1) / 2 if sides else int(flat)
        total += -value if sign == "-" else value
    return int(total)


def is_int(value, minimum=None, maximum=None):
    return (
        isinstance(value, int)
        and not isinstance(value, bool)
        and (minimum is None or value >= minimum)
        and (maximum is None or value <= maximum)
    )


def validate_damage(damage, location, errors):
    if not isinstance(damage, list) or not damage:
        errors.append(f"{location}: expected damage list")
        return
    for index, term in enumerate(damage):
        if not isinstance(term, dict) or term.get("type") not in MONSTER_DAMAGE_TYPES:
            errors.append(f"{location}[{index}]: invalid damage type")
        elif dice_average(term.get("formula")) != term.get("average"):
            errors.append(f"{location}[{index}]: average does not match formula")


def validate_monsters(monsters, conditions, pack, errors):
    """Stat blocks keep the structure a tabletop needs; see docs/ARCHITECTURE.md."""
    ids = set()
    for index, monster in enumerate(monsters):
        location = f"monsters[{index}]"
        if not isinstance(monster, dict):
            errors.append(f"{location}: expected object")
            continue
        location = f"monsters.{monster.get('name')}"
        monster_id = monster.get("id")
        expected_id = re.sub(r"[^a-z0-9]+", "_", str(monster.get("name", "")).lower()).strip("_")
        if monster_id != expected_id:
            errors.append(f"{location}: id must be {expected_id!r}")
        if monster_id in ids:
            errors.append(f"{location}: duplicate id")
        ids.add(monster_id)
        sizes = monster.get("size")
        if not isinstance(sizes, list) or not sizes or not set(sizes) <= MONSTER_SIZES:
            errors.append(f"{location}: invalid size")
        for key in ("type", "alignment"):
            if not isinstance(monster.get(key), str) or not monster[key]:
                errors.append(f"{location}: missing {key}")
        if not isinstance(monster.get("tags"), list):
            errors.append(f"{location}: tags must be a list")
        swarm = monster.get("swarm")
        if swarm is not None and (not isinstance(swarm, dict) or swarm.get("memberSize") not in MONSTER_SIZES):
            errors.append(f"{location}: invalid swarm")
        if not is_int((monster.get("armorClass") or {}).get("value"), 1, 30):
            errors.append(f"{location}: invalid armor class")
        hit_points = monster.get("hitPoints") or {}
        if not is_int(hit_points.get("average"), 1) or dice_average(hit_points.get("formula")) != hit_points["average"]:
            errors.append(f"{location}: hit point average does not match formula")
        speed = monster.get("speed")
        if not isinstance(speed, dict) or "walk" not in speed:
            errors.append(f"{location}: speed needs a walk value")
        else:
            for key, value in speed.items():
                if key == "hover":
                    valid = value is True
                elif key == "oneOf":
                    valid = isinstance(value, list) and len(value) > 1 and set(value) <= set(speed) & MONSTER_SPEEDS
                else:
                    valid = key in MONSTER_SPEEDS and is_int(value, 0)
                if not valid:
                    errors.append(f"{location}: invalid speed {key!r}")
        abilities = monster.get("abilities")
        if not isinstance(abilities, dict) or set(abilities) != set(MONSTER_ABILITIES) or not all(
            is_int(value, 1, 30) for value in abilities.values()
        ):
            errors.append(f"{location}: invalid abilities")
        for key, known in (("savingThrows", set(MONSTER_ABILITIES)), ("skills", MONSTER_SKILLS)):
            values = monster.get(key, {})
            if not isinstance(values, dict) or not set(values) <= known or not all(is_int(v) for v in values.values()):
                errors.append(f"{location}: invalid {key}")
        for key, known in (
            ("damageVulnerabilities", MONSTER_DAMAGE_TYPES),
            ("damageResistances", MONSTER_DAMAGE_TYPES),
            ("damageImmunities", MONSTER_DAMAGE_TYPES),
            ("conditionImmunities", conditions),
        ):
            values = monster.get(key, [])
            if not isinstance(values, list) or not set(values) <= known:
                errors.append(f"{location}: invalid {key}")
        senses = monster.get("senses")
        if not isinstance(senses, dict) or not is_int(senses.get("passivePerception"), 1) or not all(
            key in MONSTER_SENSES and is_int(value, 0) for key, value in senses.items() if key != "passivePerception"
        ):
            errors.append(f"{location}: invalid senses")
        languages = monster.get("languages")
        if not isinstance(languages, list) or not all(isinstance(v, str) and v.strip() for v in languages):
            errors.append(f"{location}: invalid languages")
        rating = monster.get("challengeRating")
        if rating not in CHALLENGE_RATINGS or not is_int(monster.get("experience"), 0):
            errors.append(f"{location}: invalid challenge")
        else:
            value = eval_challenge(rating)
            expected_bonus = 2 if value < 1 else 2 + (int(value) - 1) // 4
            if monster.get("proficiencyBonus") != expected_bonus:
                errors.append(f"{location}: proficiency bonus does not match challenge")
        if pack == "5.2.1":
            initiative = monster.get("initiative") or {}
            if not is_int(initiative.get("modifier")) or initiative.get("score") != 10 + initiative["modifier"]:
                errors.append(f"{location}: invalid initiative")
        if not any(monster.get(section) for section in MONSTER_SECTIONS if section != "traits") and not monster.get("traits"):
            errors.append(f"{location}: stat block has no traits or actions")
        for section in MONSTER_SECTIONS:
            entries = monster.get(section, [])
            if not isinstance(entries, list):
                errors.append(f"{location}.{section}: expected list")
                continue
            entry_ids = set()
            for entry in entries:
                entry_location = f"{location}.{section}.{entry.get('id') if isinstance(entry, dict) else '?'}"
                if not isinstance(entry, dict) or not entry.get("id") or not entry.get("name") or not str(
                    entry.get("description", "")
                ).strip():
                    errors.append(f"{entry_location}: needs id, name and description")
                    continue
                if entry["id"] in entry_ids:
                    errors.append(f"{entry_location}: duplicate id")
                entry_ids.add(entry["id"])
                attack = entry.get("attack")
                if attack is not None:
                    if attack.get("kind") not in ("melee", "ranged", "melee_or_ranged") or not is_int(attack.get("bonus")):
                        errors.append(f"{entry_location}: invalid attack")
                    if "reach" not in attack and "range" not in attack:
                        errors.append(f"{entry_location}: attack needs reach or range")
                if "damage" in entry:
                    validate_damage(entry["damage"], f"{entry_location}.damage", errors)
                save = entry.get("save")
                if save is not None:
                    if save.get("ability") not in MONSTER_ABILITIES or not is_int(save.get("dc"), 1):
                        errors.append(f"{entry_location}: invalid save")
                    if "damage" in save:
                        validate_damage(save["damage"], f"{entry_location}.save.damage", errors)
                usage = entry.get("usage")
                if usage is not None and not (
                    usage.get("type") == "recharge" and is_int(usage.get("min"), 2, 6)
                    or usage.get("type") == "per_day" and is_int(usage.get("uses"), 1)
                    or usage.get("type") == "per_rest"
                ):
                    errors.append(f"{entry_location}: invalid usage")


PACK_IDS = {"5.1": ("srd_5_1", "dnd_2014"), "5.2.1": ("srd_5_2_1", "dnd_2024")}


def validate_manifest(pack, source, errors):
    """The manifest names the license notice the app shows and which catalogs are done."""
    manifest_path = source / "manifest.json"
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"), object_pairs_hook=unique_pairs)
    except (OSError, UnicodeError, ValueError) as exc:
        errors.append(f"{manifest_path}: {exc}")
        return
    pack_id, ruleset_id = PACK_IDS[pack]
    if not isinstance(manifest, dict) or manifest.get("id") != pack_id or manifest.get("rulesetId") != ruleset_id:
        errors.append("manifest.json: invalid pack or ruleset ID")
        return
    if manifest.get("version") != pack or manifest.get("license") != "CC-BY-4.0":
        errors.append("manifest.json: invalid version or license")
    for key in ("title", "source", "licenseUrl", "attribution"):
        if not isinstance(manifest.get(key), str) or not manifest[key].strip():
            errors.append(f"manifest.json: missing {key}")
    if pack not in str(manifest.get("attribution", "")):
        errors.append("manifest.json: attribution must name the SRD version")
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
        return
    for filename in complete:
        if not (source / f"{filename}.json").is_file():
            errors.append(f"manifest.json: complete catalog {filename!r} is missing")
    if not pending and manifest.get("status") != "complete":
        errors.append("manifest.json: complete pack has unfinished status")
    if pending and manifest.get("status") != "in_progress":
        errors.append("manifest.json: pending catalogs require in_progress status")
    scope = manifest.get("catalogScope", {})
    if not isinstance(scope, dict) or not set(scope) <= set(complete) or not all(
        isinstance(text, str) and text.strip() for text in scope.values()
    ):
        errors.append("manifest.json: catalogScope must describe complete catalogs")


def eval_challenge(rating):
    numerator, _, denominator = rating.partition("/")
    return int(numerator) / int(denominator or 1)


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

            items = {
                item["name"]: item
                for section in ("weapons", "armor", "gear")
                for item in equipment.get(section, [])
                if isinstance(item, dict) and isinstance(item.get("name"), str)
            }
            for index, gear in enumerate(equipment.get("gear", [])):
                if not isinstance(gear, dict):
                    continue
                location = f"equipment.gear[{index}]"
                weight = gear.get("weight")
                if weight is not None and (not isinstance(weight, (int, float)) or weight < 0):
                    errors.append(f"{location}: invalid weight")
                contents = gear.get("contents")
                if gear.get("category") == "pack" and not contents:
                    errors.append(f"{location}: pack has no contents")
                if contents is None:
                    continue
                if not isinstance(contents, list):
                    errors.append(f"{location}: contents must be a list")
                    continue
                contents_weight = 0.0
                for content_index, content in enumerate(contents):
                    content_location = f"{location}.contents[{content_index}]"
                    if not isinstance(content, dict) or content.get("name") not in items:
                        errors.append(f"{content_location}: unknown item")
                        continue
                    quantity = content.get("quantity", 1)
                    if not isinstance(quantity, int) or isinstance(quantity, bool) or quantity < 1:
                        errors.append(f"{content_location}: invalid quantity")
                        continue
                    contents_weight += (items[content["name"]].get("weight") or 0) * quantity
                if gear.get("category") == "pack" and isinstance(weight, (int, float)):
                    if abs(weight - contents_weight) > 0.001:
                        errors.append(f"{location}: pack weight does not match contents")

            if "tools" in data:
                known_items = set(items) | {
                    tool["name"] for tool in data["tools"] if isinstance(tool, dict) and "name" in tool
                }
                for filename in ("classes", "backgrounds"):
                    for row in data.get(filename, []):
                        for choice in row.get("equipmentChoices", []):
                            for item in choice.get("items", []):
                                name = item.get("name")
                                if name and not item.get("choiceFrom") and name not in known_items:
                                    errors.append(f"{filename}.{row.get('name')}: unknown equipment {name!r}")

    if "monsters" in data:
        conditions = {
            condition["name"].lower()
            for condition in data.get("conditions", [])
            if isinstance(condition, dict) and isinstance(condition.get("name"), str)
        }
        validate_monsters(data["monsters"], conditions, pack, errors)

    if "magic_items" in data:
        magic_items = data["magic_items"]
        minimum = 262 if pack == "5.1" else 270
        if len(magic_items) < minimum:
            errors.append(f"magic_items: expected at least {minimum} SRD {pack} records")
        categories = {"armor", "weapon", "wondrous item", "potion", "ring", "rod", "scroll", "staff", "wand"}
        item_types = {"ammunition", "armor", "consumable", "container", "equippable", "gear", "weapon"}
        rarities = {"common", "uncommon", "rare", "very rare", "legendary", "artifact", "varies"}
        for index, item in enumerate(magic_items):
            location = f"magic_items[{index}]"
            if not isinstance(item, dict):
                errors.append(f"{location}: expected object")
                continue
            if item.get("type") not in categories or item.get("itemType") not in item_types:
                errors.append(f"{location}: invalid category or item type")
            if item.get("rarity") not in rarities:
                errors.append(f"{location}: invalid rarity")
            if not isinstance(item.get("requiresAttunement"), bool):
                errors.append(f"{location}: invalid attunement flag")
            if not isinstance(item.get("description"), str) or not item["description"].strip():
                errors.append(f"{location}: missing description")
            weight = item.get("weight")
            if weight is not None and (isinstance(weight, bool) or not isinstance(weight, (int, float)) or weight < 0):
                errors.append(f"{location}: invalid weight")
            cost = item.get("cost")
            if cost is not None and not isinstance(cost, str):
                errors.append(f"{location}: invalid cost")

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

    validate_manifest(pack, source, errors)

    if pack == "5.2.1":
        validate_2024_origins(data, errors)
        validate_2024_classes(data, errors)
        validate_2024_features(data, errors)
        validate_2024_feature_catalogs(data, errors)
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
