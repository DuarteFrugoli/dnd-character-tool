"""Complete 2024 mastery and invocation choices from a local SRD transcript.

Source: https://github.com/your5e/5e-srd-markdown/blob/main/dnd/521/SRD_CC_v5.2.1.md
The source transcribes the official CC-BY-4.0 SRD 5.2.1. Only the 5.2.1
catalog is modified; run after importing class progression tables.
"""

import argparse
import json
import re
from pathlib import Path


INVOCATION_PREREQUISITES = {
    "agonizing_blast": (2, [], "warlock_damage_cantrip"),
    "ascendant_step": (5, [], None),
    "devils_sight": (2, [], None),
    "devouring_blade": (12, ["thirsting_blade"], None),
    "eldritch_smite": (5, ["pact_of_the_blade"], None),
    "eldritch_spear": (2, [], "warlock_ranged_damage_cantrip"),
    "fiendish_vigor": (2, [], None),
    "gaze_of_two_minds": (5, [], None),
    "gift_of_the_depths": (5, [], None),
    "gift_of_the_protectors": (9, ["pact_of_the_tome"], None),
    "investment_of_the_chain_master": (5, ["pact_of_the_chain"], None),
    "lessons_of_the_first_ones": (2, [], "origin_feat"),
    "lifedrinker": (9, ["pact_of_the_blade"], None),
    "mask_of_many_faces": (2, [], None),
    "master_of_myriad_forms": (5, [], None),
    "misty_visions": (2, [], None),
    "one_with_shadows": (5, [], None),
    "otherworldly_leap": (2, [], None),
    "repelling_blast": (2, [], "warlock_attack_cantrip"),
    "thirsting_blade": (5, ["pact_of_the_blade"], None),
    "visions_of_distant_realms": (9, [], None),
    "whispers_of_the_grave": (7, [], None),
    "witch_sight": (15, [], None),
}

REPEATABLE = {
    "agonizing_blast", "eldritch_spear", "lessons_of_the_first_ones", "repelling_blast",
}


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", name.lower().replace("'", "")).strip("_")


def invocations(markdown: str) -> list[dict]:
    body = markdown.split("### Eldritch Invocation Options", 1)[1].split(
        "### Warlock Spell List", 1
    )[0]
    sections = re.split(r"(?m)^#### (.+)$", body)
    options = []
    for name, content in zip(sections[1::2], sections[2::2]):
        option_id = slug(name)
        level, required, target = INVOCATION_PREREQUISITES.get(option_id, (1, [], None))
        description = re.sub(r"(?m)^_Prerequisite:.*?\n", "", content)
        description = re.sub(r"_\*\*Repeatable\.\*\*_.*?(?=\n\n|\Z)", "", description, flags=re.S)
        description = re.sub(r"\*\*|_", "", description).strip()
        description = re.sub(r"\n{3,}", "\n\n", description)
        option = {"id": option_id, "name": name, "description": description}
        if level > 1:
            option["minClassLevel"] = level
        if required:
            option["requiresInvocations"] = required
        if target:
            option["target"] = target
        if option_id in REPEATABLE:
            option["repeatableWithDifferentTarget"] = True
        options.append(option)
    if len(options) != 28 or len({option["id"] for option in options}) != 28:
        raise ValueError("Expected 28 distinct Warlock invocation options")
    if {option["id"] for option in options if option.get("repeatableWithDifferentTarget")} != REPEATABLE:
        raise ValueError("Repeatable invocation metadata does not match the SRD")
    return options


def mastery_sources(weapons: list[dict]) -> dict[str, list[dict]]:
    if len(weapons) != 38 or any(not weapon.get("mastery") for weapon in weapons):
        raise ValueError("Expected all 38 SRD 5.2.1 weapons with mastery properties")

    def option(weapon: dict) -> dict:
        return {
            "id": slug(weapon["name"]),
            "name": weapon["name"],
            "description": f"{weapon['category'].title()} weapon; {weapon['mastery'].title()} mastery.",
        }

    return {
        "weapon_mastery_melee_2024": [option(w) for w in weapons if w["category"].endswith("melee")],
        "weapon_mastery_proficient_2024": [option(w) for w in weapons],
        "weapon_mastery_rogue_2024": [
            option(w) for w in weapons
            if w["category"].startswith("simple")
            or (w["category"].startswith("martial")
                and {"finesse", "light"}.intersection(w.get("properties", [])))
        ],
    }


def count_changes(rows: list[dict], key: str) -> dict[str, int]:
    previous = 0
    changes = {}
    for row in rows:
        current = row.get(key, 0)
        if current > previous:
            changes[str(row["level"])] = current - previous
        previous = current
    return changes


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--pack", required=True, type=Path)
    args = parser.parse_args()
    pack = args.pack
    markdown = args.source.read_text(encoding="utf-8")
    classes = json.loads((pack / "classes.json").read_text(encoding="utf-8"))
    equipment = json.loads((pack / "equipment.json").read_text(encoding="utf-8"))
    path = pack / "feature_choices.json"
    catalog = json.loads(path.read_text(encoding="utf-8"))
    catalog["optionSources"].update(mastery_sources(equipment["weapons"]))
    catalog["optionSources"]["eldritch_invocations_2024"] = invocations(markdown)

    for entry in classes:
        name = entry["name"]
        if name in ("Barbarian", "Fighter", "Paladin", "Ranger", "Rogue"):
            source = {
                "Barbarian": "weapon_mastery_melee_2024",
                "Rogue": "weapon_mastery_rogue_2024",
            }.get(name, "weapon_mastery_proficient_2024")
            catalog["classFeatures"][name]["Weapon Mastery"] = {
                "choices": [{
                    "id": "weapon_masteries", "type": "weapon",
                    "countByLevel": count_changes(entry["progression"], "weaponMasteryCount"),
                    "optionsSource": source,
                    "replaceOneOnLongRest": name in ("Barbarian", "Fighter"),
                    "replaceAllOnLongRest": name not in ("Barbarian", "Fighter"),
                }]
            }
        elif name == "Warlock":
            catalog["classFeatures"][name]["Eldritch Invocations"] = {
                "choices": [
                    {
                        "id": "invocations", "type": "option",
                        "countByLevel": count_changes(entry["progression"], "eldritchInvocationsKnown"),
                        "optionsSource": "eldritch_invocations_2024",
                        "replaceOneOnLevelUp": True,
                    },
                    {
                        "id": "tome_cantrips", "type": "cantrip", "count": 3,
                        "spellClass": "any", "whenChoiceId": "invocations",
                        "whenOptionId": "pact_of_the_tome", "replaceOnShortOrLongRest": True,
                    },
                    {
                        "id": "tome_rituals", "type": "spell", "count": 2,
                        "spellClass": "any", "spellLevel": 1, "ritualOnly": True,
                        "excludePreparedSpells": True, "whenChoiceId": "invocations",
                        "whenOptionId": "pact_of_the_tome", "replaceOnShortOrLongRest": True,
                    },
                ]
            }
    path.write_text(json.dumps(catalog, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(catalog['optionSources']['eldritch_invocations_2024'])} invocations and 5 mastery sets")


if __name__ == "__main__":
    main()
