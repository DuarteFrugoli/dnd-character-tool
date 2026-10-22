"""Convert the SRD 5.2.1 Magic Items A-Z Markdown into the app's JSON catalog.

Source: https://github.com/downfallx/dnd-5e-srd-markdown/blob/master/magic-items.md
The source is a transcription of the CC-BY-4.0 SRD 5.2.1 PDF named in the pack
manifest. Pass a local copy of that Markdown as --source; this tool never fetches
or overwrites data implicitly.
"""

import argparse
import html
import json
import re
from pathlib import Path


ITEM_HEADER = re.compile(
    r"(?m)^#### (.+)\n\n_((?:Armor|Weapon|Wondrous Item|Potion|Ring|Rod|Scroll|Staff|Wand)\b[^\n]+)_\n"
)
RARITY = re.compile(r"\b(Very Rare|Uncommon|Common|Rare|Legendary|Artifact)\b", re.I)
WEARABLE_PREFIXES = (
    "amulet", "belt", "boots", "bracers", "brooch", "cape", "cloak",
    "circlet", "gauntlets", "gloves", "goggles", "hat", "headband",
    "helm", "medallion", "necklace", "robe", "scarab", "slippers",
    "talisman", "winged boots", "wings of flying",
)
EXPLICIT_WEIGHTS = {
    "Apparatus of the Crab": 500,
    "Bag of Beans": 0.5,
    "Bag of Holding": 5,
    "Bead of Force": 0.0625,
    "Chime of Opening": 1,
    "Decanter of Endless Water": 2,
    "Efficient Quiver": 2,
    "Folding Boat": 4,
    "Handy Haversack": 5,
    "Iron Bands": 1,
    "Marvelous Pigments": 1,
    "Mirror of Life Trapping": 50,
}


def plain_text(markdown: str) -> str:
    text = re.sub(r"</(?:td|th)>\s*<(?:td|th)>", " | ", markdown)
    text = re.sub(r"</tr>", "\n", text)
    text = re.sub(r"<br\s*/?>", "\n", text)
    text = re.sub(r"<hr\s*/?>", "\n", text)
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text)
    text = re.sub(r"(?m)^#{1,6}\s+", "", text)
    text = text.replace("**", "").replace("_", "").replace("*", "")
    text = text.replace("\u2019", "'").replace("\u201c", '"').replace("\u201d", '"')
    text = text.replace("\u2013", "-").replace("\u2014", " - ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n[ \t]+", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def item_type(name: str, category: str, description: str) -> str:
    lower = name.lower()
    if category == "armor":
        return "armor"
    if category == "weapon":
        return "ammunition" if lower.startswith("ammunition") else "weapon"
    if category in ("potion", "scroll"):
        return "consumable"
    if lower in ("bag of holding", "bag of devouring", "handy haversack", "portable hole"):
        return "container"
    if category in ("ring", "rod", "staff", "wand"):
        return "equippable"
    if lower.startswith(WEARABLE_PREFIXES) or re.search(
        r"\bwhile (?:you )?(?:wear|wearing)\b", description[:500], re.I
    ):
        return "equippable"
    return "gear"


def catalog_entry(name: str, heading: str, body: str, equipment_weights: dict[str, float]) -> dict:
    category = heading.split(" ", 2)
    if heading.startswith("Wondrous Item"):
        category_name = "wondrous item"
    else:
        category_name = category[0].lower().split("(")[0].strip(",")
    rarities = {rarity.lower() for rarity in RARITY.findall(heading)}
    rarity = next(iter(rarities)) if len(rarities) == 1 and "Rarity Varies" not in heading else "varies"
    description = plain_text(body)
    prefixes = []
    base_item = re.match(r"(?:Armor|Weapon) \(([^)]+)\)", heading)
    if base_item:
        prefixes.append(f"Base item: {base_item.group(1)}.")
    attunement = re.search(r"Requires Attunement(?: by ([^)]+))?", heading)
    if attunement and attunement.group(1):
        prefixes.append(f"Requires attunement by {attunement.group(1)}.")
    if prefixes:
        description = "\n\n".join([*prefixes, description])
    weight = EXPLICIT_WEIGHTS.get(name)
    if weight is None and base_item:
        weight = equipment_weights.get(base_item.group(1))
    return {
        "name": name,
        "type": category_name,
        "itemType": item_type(name, category_name, description),
        "rarity": rarity,
        "requiresAttunement": attunement is not None,
        "weight": weight,
        "cost": None,
        "description": description,
    }


def healing_potions() -> list[dict]:
    variants = (
        ("Potion of Healing", "common", "2d4 + 2", "50 gp"),
        ("Potion of Healing (greater)", "uncommon", "4d4 + 4", None),
        ("Potion of Healing (superior)", "rare", "8d4 + 8", None),
        ("Potion of Healing (supreme)", "very rare", "10d4 + 20", None),
    )
    return [
        {
            "name": name,
            "type": "potion",
            "itemType": "consumable",
            "rarity": rarity,
            "requiresAttunement": False,
            "weight": 0.5,
            "cost": cost,
            "description": f"Drinking this potion as a Bonus Action restores {healing} Hit Points. Its red liquid glimmers when shaken.",
        }
        for name, rarity, healing, cost in variants
    ]


def spell_scrolls(body: str) -> list[dict]:
    before_table, after_table = re.split(r"<table>.*?</table>", body, maxsplit=1, flags=re.S)
    before_table = re.sub(
        r"The level of the spell on the scroll determines the spell's saving throw DC"
        r" and attack bonus, as well as the scroll's rarity, as shown in the following table\.",
        "",
        before_table,
    )
    rules = plain_text(before_table + "\n\n" + after_table)
    levels = (
        ("Cantrip", "common", 13, 5),
        ("Level 1", "common", 13, 5),
        ("Level 2", "uncommon", 13, 5),
        ("Level 3", "uncommon", 15, 7),
        ("Level 4", "rare", 15, 7),
        ("Level 5", "rare", 17, 9),
        ("Level 6", "very rare", 17, 9),
        ("Level 7", "very rare", 18, 10),
        ("Level 8", "very rare", 18, 10),
        ("Level 9", "legendary", 19, 11),
    )
    return [
        {
            "name": f"Spell Scroll ({level})",
            "type": "scroll",
            "itemType": "consumable",
            "rarity": rarity,
            "requiresAttunement": False,
            "weight": None,
            "cost": "30 gp" if level == "Cantrip" else "50 gp" if level == "Level 1" else None,
            "description": f"Contains one {level.lower()} spell chosen by its creator. Spell save DC {dc}; spell attack bonus +{attack}.\n\n{rules}",
        }
        for level, rarity, dc, attack in levels
    ]


def convert(markdown: str, equipment_weights: dict[str, float]) -> list[dict]:
    section = re.split(r"(?m)^## Magic Items A\S+Z\s*$", markdown, maxsplit=1)[1]
    headers = list(ITEM_HEADER.finditer(section))
    if len(headers) != 258:
        raise ValueError(f"Expected 258 SRD magic item entries, found {len(headers)}")
    items = []
    for index, match in enumerate(headers):
        name, heading = match.groups()
        body = section[match.end():headers[index + 1].start() if index + 1 < len(headers) else None].strip()
        if name == "Potions of Healing":
            items.extend(healing_potions())
        elif name == "Spell Scroll":
            items.extend(spell_scrolls(body))
        else:
            items.append(catalog_entry(name, heading, body, equipment_weights))
    names = [item["name"] for item in items]
    if len(names) != len(set(names)) or any(not item["description"] for item in items):
        raise ValueError("Magic item names must be unique and descriptions nonempty")
    return sorted(items, key=lambda item: item["name"].lower())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path, help="local magic-items.md")
    parser.add_argument("--equipment", required=True, type=Path, help="5.2.1 equipment.json")
    parser.add_argument("--output", required=True, type=Path, help="magic_items.json")
    args = parser.parse_args()
    equipment = json.loads(args.equipment.read_text(encoding="utf-8"))
    equipment_weights = {
        item["name"]: item["weight"]
        for section in ("weapons", "armor")
        for item in equipment[section]
        if item.get("weight") is not None
    }
    items = convert(args.source.read_text(encoding="utf-8"), equipment_weights)
    args.output.write_text(json.dumps(items, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(items)} magic item records to {args.output}")


if __name__ == "__main__":
    main()
