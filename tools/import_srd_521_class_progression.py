"""Import the twelve SRD 5.2.1 class progression tables into classes.json.

Source: https://github.com/your5e/5e-srd-markdown/blob/main/dnd/521/SRD_CC_v5.2.1.md
The source transcribes the official CC-BY-4.0 SRD 5.2.1. This tool takes a
local copy and does not download content or modify the 5.1 pack.
"""

import argparse
import json
import re
from pathlib import Path


COLUMN_KEYS = {
    "Rages": "rageUses",
    "Rage Damage": "rageDamageBonus",
    "Weapon Mastery": "weaponMasteryCount",
    "Bardic Die": "bardicDie",
    "Cantrips": "cantripsKnown",
    "Prepared Spells": "preparedSpells",
    "Channel Divinity": "channelDivinityUses",
    "Wild Shape": "wildShapeUses",
    "Second Wind": "secondWindUses",
    "Martial Arts": "martialArtsDie",
    "Focus Points": "focusPoints",
    "Unarmored Movement": "unarmoredMovementBonusFeet",
    "Favored Enemy": "favoredEnemyFreeCasts",
    "Sneak Attack": "sneakAttackDice",
    "Sorcery Points": "sorceryPoints",
    "Eldritch Invocations": "eldritchInvocationsKnown",
    "Spell Slots": "pactMagicSlots",
    "Slot Level": "pactMagicSlotLevel",
}


def cells(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def number(value: str) -> int:
    value = value.strip()
    if value in ("", "—", "-"):
        return 0
    return int(value.lstrip("+"))


def table_for(markdown: str, class_name: str) -> list[dict]:
    heading = re.search(rf"(?m)^### {re.escape(class_name)} Class Features$", markdown)
    if heading is None:
        raise ValueError(f"Missing class progression table: {class_name}")
    table_lines = []
    for line in markdown[heading.end():].splitlines():
        if line.startswith("|"):
            table_lines.append(line)
        elif table_lines:
            break
    headers = cells(table_lines[0])
    if headers[:3] != ["Level", "Proficiency Bonus", "Class Features"]:
        raise ValueError(f"Unexpected progression columns for {class_name}: {headers}")
    rows = [cells(line) for line in table_lines[2:]]
    if len(rows) != 20 or any(len(row) != len(headers) for row in rows):
        raise ValueError(f"Expected twenty complete levels for {class_name}")
    progression = []
    for expected_level, row in enumerate(rows, 1):
        level = number(row[0])
        if level != expected_level:
            raise ValueError(f"Unexpected {class_name} level {level}, expected {expected_level}")
        result = {
            "level": level,
            "proficiencyBonus": number(row[1]),
            "features": [
                name.strip() for name in row[2].split(",")
                if name.strip() not in ("\u2014", "-")
            ],
        }
        for index, header in enumerate(headers[3:], 3):
            if header == "Spell Slots - 1st":
                result["spellSlots"] = [number(slot) for slot in row[index:]]
                break
            if header not in COLUMN_KEYS:
                raise ValueError(f"Unknown {class_name} progression column {header}")
            key = COLUMN_KEYS[header]
            value = row[index]
            if key in ("bardicDie", "martialArtsDie", "sneakAttackDice"):
                result[key] = value.lower() if value != "—" else ""
            elif key == "unarmoredMovementBonusFeet":
                result[key] = number(value.replace(" ft.", ""))
            else:
                result[key] = number(value)
        if class_name in ("Paladin", "Ranger", "Rogue"):
            result["weaponMasteryCount"] = 2
        progression.append(result)
    return progression


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--classes", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    markdown = args.source.read_text(encoding="utf-8")
    classes = json.loads(args.classes.read_text(encoding="utf-8"))
    if len(classes) != 12:
        raise ValueError("Expected twelve SRD 5.2.1 classes")
    for class_entry in classes:
        class_entry["progression"] = table_for(markdown, class_entry["name"])
    args.output.write_text(json.dumps(classes, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote 240 class progression rows to {args.output}")


if __name__ == "__main__":
    main()
