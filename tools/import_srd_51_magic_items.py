"""Build the SRD 5.1 magic-item catalog from a local CC-BY-4.0 Markdown copy.

Source: https://github.com/your5e/5e-srd-markdown/blob/main/dnd/51/SRD_CC_v5.1.md
The Markdown is a transcription of the official SRD 5.1. This script never
downloads it or changes existing character records.
"""

import argparse
import html
import json
import re
from pathlib import Path


ENTRY = re.compile(r"(?m)^## ([^\n]+)\n\n_([^\n]+)_\n")
RARITY = re.compile(r"\b(very rare|uncommon|common|rare|legendary|artifact)\b", re.I)
WEARABLE = (
    "amulet", "belt", "boots", "bracers", "brooch", "cape", "cloak",
    "circlet", "gauntlets", "gloves", "goggles", "hat", "headband",
    "helm", "ioun stone", "medallion", "necklace", "robe", "scarab",
    "slippers", "talisman", "winged boots", "wings of flying",
)
BONUS_FAMILIES = {
    "Ammunition, +1, +2, or +3": ("Ammunition", "ammunition"),
    "Armor, +1, +2, or +3": ("Armor", "armor"),
    "Shield, +1, +2, or +3": ("Shield", "armor"),
    "Wand of the War Mage, +1, +2, or +3": ("Wand of the War Mage", "equippable"),
    "Weapon, +1, +2, or +3": ("Weapon", "weapon"),
}
KNOWN_WEIGHTS = {
    "Apparatus of the Crab": 500,
    "Bag of Beans": 0.5,
    "Bag of Holding": 15,
    "Chime of Opening": 1,
    "Decanter of Endless Water": 2,
    "Efficient Quiver": 2,
    "Folding Boat": 4,
    "Handy Haversack": 5,
    "Mirror of Life Trapping": 50,
}


def clean_inline(text: str) -> str:
    text = re.sub(r"\[([^]]+)\]\([^)]+\)", r"\1", text)
    text = text.replace("**", "").replace("__", "").replace("*", "").replace("_", "")
    return html.unescape(text).strip()


def plain_text(markdown: str) -> str:
    lines = markdown.strip().splitlines()
    rendered = []
    table_headings = None
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("|") and stripped.endswith("|"):
            cells = [clean_inline(cell) for cell in stripped.strip("|").split("|")]
            if all(re.fullmatch(r"[-: ]+", cell) for cell in cells):
                continue
            if table_headings is None:
                table_headings = cells
            else:
                rendered.append("; ".join(
                    f"{heading}: {value}" if heading else value
                    for heading, value in zip(table_headings, cells)
                ))
            continue
        table_headings = None
        line = re.sub(r"^#{1,6}\s+", "", line)
        rendered.append(clean_inline(line))
    text = "\n".join(rendered)
    return re.sub(r"\n{3,}", "\n\n", text).strip()


def sections(markdown: str) -> list[tuple[str, str, str]]:
    main = markdown.split("# Magic Items A-Z\n", 1)[1].split("# Sentient Magic Items\n", 1)[0]
    artifact = markdown.split("# Artifacts\n", 1)[1].split("# Monsters\n", 1)[0]
    result = []
    for section in (main, artifact):
        headings = list(ENTRY.finditer(section))
        for index, match in enumerate(headings):
            body = section[match.end():headings[index + 1].start() if index + 1 < len(headings) else None]
            result.append((match.group(1), match.group(2), body.strip()))
    if len(result) != 240:
        raise ValueError(f"Expected 239 alphabetical items and one artifact, found {len(result)}")
    return result


def category(header: str) -> str:
    if header.lower().startswith("wondrous item"):
        return "wondrous item"
    return header.split(" ", 1)[0].split(",", 1)[0].lower()


def item_type(name: str, kind: str, description: str) -> str:
    lower = name.lower()
    if kind == "armor":
        return "armor"
    if kind == "weapon":
        return "ammunition" if lower.startswith(("ammunition", "arrow of")) else "weapon"
    if kind in ("potion", "scroll"):
        return "consumable"
    if lower in ("bag of holding", "bag of devouring", "handy haversack", "portable hole"):
        return "container"
    if kind in ("ring", "rod", "staff", "wand"):
        return "equippable"
    if lower.startswith(WEARABLE) or re.search(r"\bwhile (?:you )?(?:wear|wearing)\b", description[:500], re.I):
        return "equippable"
    return "gear"


def entry(name: str, header: str, body: str, weights: dict[str, float], legacy: dict) -> dict:
    kind = category(header)
    found = {value.lower() for value in RARITY.findall(header)}
    rarity = found.pop() if len(found) == 1 and "varies" not in header.lower() else "varies"
    attunement = re.search(r"requires attunement(?: by ([^)]+))?", header, re.I)
    base = re.match(r"(?:Armor|Weapon) \(([^)]+)\)", header, re.I)
    description = plain_text(body)
    prefixes = []
    if base:
        prefixes.append(f"Base item: {base.group(1)}.")
    if attunement and attunement.group(1):
        prefixes.append(f"Requires attunement by {attunement.group(1)}.")
    if prefixes:
        description = "\n\n".join([*prefixes, description])
    old = legacy.get(name, {})
    weight = KNOWN_WEIGHTS.get(name)
    if weight is None and base:
        weight = weights.get(base.group(1).casefold())
    if weight is None:
        weight = old.get("weight")
    cost = old.get("cost")
    if cost and not re.fullmatch(r"[\d.]+\s+(?:cp|sp|ep|gp|pp)", cost):
        cost = None
    result = {
        "name": name,
        "type": kind,
        "itemType": item_type(name, kind, description),
        "rarity": rarity,
        "requiresAttunement": attunement is not None,
        "weight": weight,
        "cost": cost,
        "description": description,
    }
    for key in ("effect", "features"):
        if key in old:
            result[key] = old[key]
    return result


def bonus_items(name: str, header: str, body: str, weights: dict[str, float], legacy: dict) -> list[dict]:
    base_name, kind = BONUS_FAMILIES[name]
    rarity_by_bonus = {
        int(bonus): rarity.lower()
        for rarity, bonus in re.findall(r"(uncommon|very rare|rare|legendary) \(\+(\d)\)", header, re.I)
    }
    if set(rarity_by_bonus) != {1, 2, 3}:
        raise ValueError(f"Missing enhancement rarities for {name}")
    result = []
    for bonus in (1, 2, 3):
        variant_name = f"+{bonus} {base_name}" if base_name in ("Weapon", "Armor", "Shield", "Ammunition") else f"{base_name} +{bonus}"
        item = entry(variant_name, header, body, weights, legacy)
        item["itemType"] = kind
        item["rarity"] = rarity_by_bonus[bonus]
        description = item["description"]
        if base_name == "Shield":
            description = description.replace(
                "a bonus to AC determined by the shield's rarity", f"a +{bonus} bonus to AC"
            )
        elif base_name == "Wand of the War Mage":
            description = description.replace(
                "a bonus to spell attack rolls determined by the wand's rarity",
                f"a +{bonus} bonus to spell attack rolls",
            )
        else:
            description = description.replace("a bonus to", f"a +{bonus} bonus to", 1)
            description = re.sub(r" The bonus is determined by [^.]+\.", "", description)
        item["description"] = description
        result.append(item)
    return result


def healing_potions(body: str, legacy: dict) -> list[dict]:
    variants = (
        ("Potion of Healing", "common", "2d4 + 2"),
        ("Potion of Greater Healing", "uncommon", "4d4 + 4"),
        ("Potion of Superior Healing", "rare", "8d4 + 8"),
        ("Potion of Supreme Healing", "very rare", "10d4 + 20"),
    )
    rules = plain_text(body.split("### Potions of Healing", 1)[0])
    rules = re.sub(
        r"You regain hit points when you drink this potion\. The number of hit points depends on the potion's rarity, as shown in the Potions of Healing table\.",
        "",
        rules,
    ).strip()
    return [
        {
            "name": name,
            "type": "potion",
            "itemType": "consumable",
            "rarity": rarity,
            "requiresAttunement": False,
            "weight": legacy.get(name, {}).get("weight", 0.5),
            "cost": legacy.get(name, {}).get("cost"),
            "description": f"You regain {healing} hit points when you drink this potion.\n\n{rules}",
            "effect": legacy.get(name, {}).get("effect", "heal_" + healing.replace(" + ", "p")),
        }
        for name, rarity, healing in variants
    ]


def spell_scrolls(body: str) -> list[dict]:
    before, after = body.split("### Spell Scroll", 1)
    after_table = after.split("\n\nA wizard spell", 1)[1]
    rules = plain_text(before + "\n\nA wizard spell" + after_table)
    rules = rules.replace(
        "The level of the spell on the scroll determines the spell's saving throw DC and attack bonus, as well as the scroll's rarity, as shown in the Spell Scroll table.",
        "",
    )
    levels = (
        ("Cantrip", "common", 13, 5), ("Level 1", "common", 13, 5),
        ("Level 2", "uncommon", 13, 5), ("Level 3", "uncommon", 15, 7),
        ("Level 4", "rare", 15, 7), ("Level 5", "rare", 17, 9),
        ("Level 6", "very rare", 17, 9), ("Level 7", "very rare", 18, 10),
        ("Level 8", "very rare", 18, 10), ("Level 9", "legendary", 19, 11),
    )
    return [
        {
            "name": f"Spell Scroll ({level})", "type": "scroll", "itemType": "consumable",
            "rarity": rarity, "requiresAttunement": False, "weight": None, "cost": None,
            "description": f"Contains a {level.lower()} spell chosen by its creator. Spell save DC {dc}; spell attack bonus +{attack}.\n\n{rules}",
        }
        for level, rarity, dc, attack in levels
    ]


def convert(markdown: str, equipment: dict, legacy_items: list[dict]) -> list[dict]:
    weights = {
        item["name"].casefold(): item["weight"]
        for group in ("weapons", "armor") for item in equipment[group]
        if item.get("weight") is not None
    }
    legacy = {item["name"]: item for item in legacy_items}
    items = []
    for name, header, body in sections(markdown):
        if name == "Potion of Healing":
            items.extend(healing_potions(body, legacy))
        elif name == "Spell Scroll":
            items.extend(spell_scrolls(body))
        elif name in BONUS_FAMILIES:
            items.extend(bonus_items(name, header, body, weights, legacy))
        else:
            items.append(entry(name, header, body, weights, legacy))
    names = [item["name"] for item in items]
    if len(names) != len(set(names)) or not set(legacy) <= set(names):
        raise ValueError("Duplicate names or missing existing catalog items")
    if any(not item["description"] for item in items):
        raise ValueError("Empty magic-item description")
    return sorted(items, key=lambda item: item["name"].casefold())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True, help="local SRD_CC_v5.1.md")
    parser.add_argument("--equipment", type=Path, required=True, help="5.1 equipment.json")
    parser.add_argument("--existing", type=Path, required=True, help="current 5.1 magic_items.json")
    parser.add_argument("--output", type=Path, required=True, help="new 5.1 magic_items.json")
    args = parser.parse_args()
    items = convert(
        args.source.read_text(encoding="utf-8"),
        json.loads(args.equipment.read_text(encoding="utf-8")),
        json.loads(args.existing.read_text(encoding="utf-8")),
    )
    args.output.write_text(json.dumps(items, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(items)} magic item records to {args.output}")


if __name__ == "__main__":
    main()
