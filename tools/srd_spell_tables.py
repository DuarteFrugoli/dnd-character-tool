"""Layout fixes for spells whose tables and stat blocks do not extract cleanly
from the SRD PDFs. Tables become one row per line ("2-6: The creature ...").
Used by import_srd_spells.py."""

import re

DASH = "—"


def rows(*lines):
    return "\n".join(lines)


FIXES = {
    "5.1": {
        "Confusion": [(
            "for that turn. d10 Behavior 1 The creature uses all its movement to move in a random direction. "
            "To determine the direction, roll a d8 and assign a direction to each die face. The creature doesn't "
            "take an action this turn. 2-6 The creature doesn't move or take actions this turn. 7-8 The creature "
            "uses its action to make a melee attack against a randomly determined creature within its reach. If "
            "there is no creature within its reach, the creature does nothing this turn. 9-10 The creature can act "
            "and move normally.",
            "for that turn.\n\n" + rows(
                "d10: Behavior",
                "1: The creature uses all its movement to move in a random direction. To determine the direction, "
                "roll a d8 and assign a direction to each die face. The creature doesn't take an action this turn.",
                "2-6: The creature doesn't move or take actions this turn.",
                "7-8: The creature uses its action to make a melee attack against a randomly determined creature "
                "within its reach. If there is no creature within its reach, the creature does nothing this turn.",
                "9-10: The creature can act and move normally.",
            ),
        )],
        "Animate Objects": [(
            "until its task is complete. Animated Object Statistics Size HP AC Attack Str Dex Tiny 20 18 +8 to hit, "
            "1d4 + 4 damage 4 18 Small 25 16 +6 to hit, 1d8 + 2 damage 6 14 Medium 40 13 +5 to hit, 2d6 + 1 damage "
            "10 12 Large 50 10 +6 to hit, 2d10 + 2 14 10 damage Huge 80 10 +8 to hit, 2d12 + 4 18 6 damage An "
            "animated object",
            "until its task is complete.\n\n" + rows(
                "Animated Object Statistics",
                "Tiny: HP 20, AC 18, Attack +8 to hit, 1d4 + 4 damage, Str 4, Dex 18",
                "Small: HP 25, AC 16, Attack +6 to hit, 1d8 + 2 damage, Str 6, Dex 14",
                "Medium: HP 40, AC 13, Attack +5 to hit, 2d6 + 1 damage, Str 10, Dex 12",
                "Large: HP 50, AC 10, Attack +6 to hit, 2d10 + 2 damage, Str 14, Dex 10",
                "Huge: HP 80, AC 10, Attack +8 to hit, 2d12 + 4 damage, Str 18, Dex 6",
            ) + "\n\nAn animated object",
        ), (
            "is blind beyond that distance. When the animated object",
            "is blind beyond that distance.\n\nWhen the animated object",
        ), (
            "original object form. If you command an object",
            "original object form.\n\nIf you command an object",
        )],
        "Creation": [(
            "use the shortest duration. Material Duration Vegetable matter 1 day Stone or crystal 12 hours Precious "
            "metals 1 hour Gems 10 minutes Adamantine or mithral 1 minute Using any material",
            "use the shortest duration.\n\n" + rows(
                "Material: Duration",
                "Vegetable matter: 1 day",
                "Stone or crystal: 12 hours",
                "Precious metals: 1 hour",
                "Gems: 10 minutes",
                "Adamantine or mithral: 1 minute",
            ) + "\n\nUsing any material",
        )],
        "Reincarnate": [(
            "or the GM chooses a form. d100 Race 01-04 Dragonborn 05-13 Dwarf, hill 14-21 Dwarf, mountain 22-25 Elf, "
            "dark 26-34 Elf, high 35-42 Elf, wood 43-46 Gnome, forest 47-52 Gnome, rock 53-56 Half-elf 57-60 "
            "Half-orc 61-68 Halfling, lightfoot 69-76 Halfling, stout 77-96 Human 97-00 Tiefling",
            "or the GM chooses a form.\n\n" + rows(
                "d100: Race", "01-04: Dragonborn", "05-13: Dwarf, hill", "14-21: Dwarf, mountain",
                "22-25: Elf, dark", "26-34: Elf, high", "35-42: Elf, wood", "43-46: Gnome, forest",
                "47-52: Gnome, rock", "53-56: Half-elf", "57-60: Half-orc", "61-68: Halfling, lightfoot",
                "69-76: Halfling, stout", "77-96: Human", "97-00: Tiefling",
            ),
        )],
        "Teleport": [(
            re.compile(r"consults the table\. Similar Off On Familiarity .*? destination Familiarity\. ", re.S),
            "consults the table.\n\n" + rows(
                "Familiarity: Mishap, Similar Area, Off Target, On Target",
                f"Permanent circle: {DASH}, {DASH}, {DASH}, 01-100",
                f"Associated object: {DASH}, {DASH}, {DASH}, 01-100",
                "Very familiar: 01-05, 06-13, 14-24, 25-100",
                "Seen casually: 01-33, 34-43, 44-53, 54-100",
                "Viewed once: 01-43, 44-53, 54-73, 74-100",
                "Description: 01-43, 44-53, 54-73, 74-100",
                f"False destination: 01-50, 51-100, {DASH}, {DASH}",
            ) + "\n\nFamiliarity. ",
        ), (
            " On Target. You and your group", "\n\nOn Target. You and your group",
        ), (
            " Off Target. You and your group", "\n\nOff Target. You and your group",
        )],
        "Control Weather": [(
            "you can change its direction. Precipitation Stage 1 2 3 4 5 Condition Clear Light clouds Overcast or "
            "ground fog Rain, hail, or snow Torrential rain, driving hail, or blizzard Temperature Stage Condition 1 "
            "Unbearable heat 2 Hot 3 Warm 4 Cool 5 Cold 6 Arctic cold Wind Stage 1 2 3 4 5 Condition Calm Moderate "
            "wind Strong wind Gale Storm",
            "you can change its direction.\n\n" + rows(
                "Precipitation", "1: Clear", "2: Light clouds", "3: Overcast or ground fog",
                "4: Rain, hail, or snow", "5: Torrential rain, driving hail, or blizzard",
            ) + "\n\n" + rows(
                "Temperature", "1: Unbearable heat", "2: Hot", "3: Warm", "4: Cool", "5: Cold", "6: Arctic cold",
            ) + "\n\n" + rows(
                "Wind", "1: Calm", "2: Moderate wind", "3: Strong wind", "4: Gale", "5: Storm",
            ),
        )],
        "Prismatic Spray": [("three of a kind.. Violet.", "three of a kind.\n\n7. Violet.")],
        "Scrying": [(
            "if it wants to be observed. Knowledge Secondhand (you have heard of the target) Firsthand (you have met "
            "the target) Familiar (you know the target well) Connection Likeness or picture Possession or garment "
            "Body part, lock of hair, bit of nail, or the like\n\nSave Modifier +5 +0 -5 Save Modifier -2 -4 -10 "
            "On a successful save",
            "if it wants to be observed.\n\n" + rows(
                "Knowledge: Save Modifier",
                "Secondhand (you have heard of the target): +5",
                "Firsthand (you have met the target): +0",
                "Familiar (you know the target well): -5",
            ) + "\n\n" + rows(
                "Connection: Save Modifier",
                "Likeness or picture: -2",
                "Possession or garment: -4",
                "Body part, lock of hair, bit of nail, or the like: -10",
            ) + "\n\nOn a successful save",
        )],
        # A distance in words would stay in feet in every unit system.
        "Bigby's Hand": [(
            "plus a number of feet equal to five times your spellcasting ability modifier",
            "plus 5 feet times your spellcasting ability modifier",
        )],
    },
    "5.2.1": {
        "Augury": [(
            "Omens Omen Weal Woe Weal and woe Indifference For Results That Will Be... Good Bad Good and bad "
            "Neither good nor bad The spell doesn't",
            rows("Omens", "Omen: For Results That Will Be...", "Weal: Good", "Woe: Bad", "Weal and woe: Good and bad",
                 "Indifference: Neither good nor bad") + "\n\nThe spell doesn't",
        )],
        "Arcane Hand": [(
            "plus a number of feet equal to five times your spellcasting ability modifier",
            "plus 5 feet times your spellcasting ability modifier",
        )],
        "Confusion": [
            ("1d10 Behavior for the Turn 1 The target", "1d10: Behavior for the Turn\n1: The target"),
            ("4, west.\n\n2-6 The target", "4, west.\n2-6: The target"),
            ("take actions.\n\n7-8 The target", "take actions.\n7-8: The target"),
            ("no action.\n\n9-10 The target", "no action.\n9-10: The target"),
        ],
        "Creation": [(
            "Materials Material Vegetable matter Stone or crystal Precious metals Gems Adamantine or mithral "
            "Duration 24 hours 12 hours 1 hour 10 minutes 1 minute",
            rows("Materials", "Vegetable matter: 24 hours", "Stone or crystal: 12 hours", "Precious metals: 1 hour",
                 "Gems: 10 minutes", "Adamantine or mithral: 1 minute"),
        )],
        "Reincarnate": [(
            "1d10 Species 1 Roll again. 2 Dragonborn 3 Dwarf 4 Elf 5 Gnome 1d10 Species 6 Goliath 7 Halfling 8 Human "
            "9 Orc 10 Tiefling The reincarnated",
            rows("1d10: Species", "1: Roll again.", "2: Dragonborn", "3: Dwarf", "4: Elf", "5: Gnome", "6: Goliath",
                 "7: Halfling", "8: Human", "9: Orc", "10: Tiefling") + "\n\nThe reincarnated",
        )],
        "Divine Word": [
            ("Divine Word Effects Hit Points Effect 0-20 The target dies.",
             "Divine Word Effects\nHit Points: Effect\n0-20: The target dies."),
            ("dies.\n\n21-30 The target", "dies.\n21-30: The target"),
            ("for 1 hour.\n\n31-40 The target", "for 1 hour.\n31-40: The target"),
            ("for 10 minutes.\n\n41-50 The target", "for 10 minutes.\n41-50: The target"),
        ],
        "Prismatic Spray": [
            ("Prismatic Rays 1d8 Ray 1 Red.", "Prismatic Rays\n1d8: Ray\n1: Red."),
            ("damage.\n\n2 Orange.", "damage.\n2: Orange."),
            ("damage.\n\n3 Yellow.", "damage.\n3: Yellow."),
            ("damage.\n\n4 Green.", "damage.\n4: Green."),
            ("damage.\n\n1d8 Ray 5 Blue.", "damage.\n5: Blue."),
            ("damage.\n\n6 Indigo.", "damage.\n6: Indigo."),
            ("of a kind.\n\n7 Violet.", "of a kind.\n7: Violet."),
            ("(GM's choice).\n\n8 Special.", "(GM's choice).\n8: Special."),
        ],
        "Prismatic Wall": [
            ("Prismatic Layers Order Effects 1 Red.", "Prismatic Layers\n1: Red."),
            ("Cold damage.\n\n2 Orange.", "Cold damage.\n2: Orange."),
            ("Gust of Wind).\n\n3 Yellow.", "Gust of Wind).\n3: Yellow."),
            ("Force damage.\n\n4 Green.", "Force damage.\n4: Green."),
            ("destroys this layer.\n\n5 Blue.", "destroys this layer.\n5: Blue."),
            ("Fire damage.\n\n6 Indigo.", "Fire damage.\n6: Indigo."),
            ("Daylight spell.\n\n7 Violet.", "Daylight spell.\n7: Violet."),
        ],
        "Scrying": [(
            "Your Knowledge of the Target Is... Secondhand (heard of the target) Firsthand (met the target) "
            "Extensive (know the target well)\n\nSave Modifier +5 +0 -5 You Have the Target's... Picture or other "
            "likeness Garment or other possession Body part, lock of hair, or bit of nail Save Modifier -2 -4 -10 "
            "On a successful save",
            rows(
                "Your Knowledge of the Target Is...: Save Modifier",
                "Secondhand (heard of the target): +5",
                "Firsthand (met the target): +0",
                "Extensive (know the target well): -5",
            ) + "\n\n" + rows(
                "You Have the Target's...: Save Modifier",
                "Picture or other likeness: -2",
                "Garment or other possession: -4",
                "Body part, lock of hair, or bit of nail: -10",
            ) + "\n\nOn a successful save",
        )],
        # The 5.2.1 PDF cuts the last sentence; it ends as in the 5.1 text.
        "Telekinesis": [(
            "such as manipulating a simple tool,",
            "such as manipulating a simple tool, opening a door or a container, stowing or retrieving an item "
            "from an open container, or pouring the contents from a vial.",
        )],
        "Teleport": [(
            re.compile(r"Teleportation Outcome Familiarity .*?-- Familiarity\. ", re.S),
            rows(
                "Teleportation Outcome",
                "Familiarity: Mishap, Similar Area, Off Target, On Target",
                f"Permanent circle: {DASH}, {DASH}, {DASH}, 01-00",
                f"Linked object: {DASH}, {DASH}, {DASH}, 01-00",
                "Very familiar: 01-05, 06-13, 14-24, 25-00",
                "Seen casually: 01-33, 34-43, 44-53, 54-00",
                "Viewed once or described: 01-43, 44-53, 54-73, 74-00",
                f"False destination: 01-50, 51-00, {DASH}, {DASH}",
            ) + "\n\nFamiliarity. ",
        ), ("\n\n- \"", "\n\"")],
        "Control Weather": [(
            "Precipitation Stage Condition 1 Clear 2 Light clouds 3 Overcast or ground fog 4 Rain, hail, or snow 5 "
            "Torrential rain, driving hail, or blizzard Temperature Stage Condition 1 Heat wave 2 Hot 3 Warm 4 Cool "
            "5 Cold 6 Freezing Wind Stage Condition 1 Calm 2 Moderate wind 3 Strong wind 4 Gale 5 Storm",
            rows("Precipitation", "1: Clear", "2: Light clouds", "3: Overcast or ground fog", "4: Rain, hail, or snow",
                 "5: Torrential rain, driving hail, or blizzard")
            + "\n\n" + rows("Temperature", "1: Heat wave", "2: Hot", "3: Warm", "4: Cool", "5: Cold", "6: Freezing")
            + "\n\n" + rows("Wind", "1: Calm", "2: Moderate wind", "3: Strong wind", "4: Gale", "5: Storm"),
        )],
    },
}

ABILITY_TABLE = re.compile(
    r"MOD SAVE MOD SAVE MOD SAVE ((?:(?:Str|Dex|Con|Int|Wis|Cha) \d+ [+-]\d+ [+-]\d+ ?){6})"
)
STAT_FIELDS = ("AC", "HP", "Speed", "Skills", "Resistances", "Immunities", "Senses", "Languages", "CR")
SECTIONS = ("Traits", "Actions", "Bonus Actions", "Reactions")


def format_stat_block(text):
    """Spell stat blocks (2024) as one field per line."""
    def abilities(m):
        parts = []
        for name, score, mod, save in re.findall(r"(Str|Dex|Con|Int|Wis|Cha) (\d+) ([+-]\d+) ([+-]\d+)", m.group(1)):
            parts.append(f"{name} {score} ({mod})" + (f", save {save}" if save != mod else ""))
        return "\n" + ", ".join(parts) + "\n"

    paragraphs = text.split("\n\n")
    out = []
    for paragraph in paragraphs:
        if ABILITY_TABLE.search(paragraph):
            paragraph = ABILITY_TABLE.sub(abilities, paragraph).strip()
            paragraph = re.sub(r" (Skills|Resistances|Immunities|Senses|Languages|CR) ", r"\n\1 ", paragraph)
            out[-1] = out[-1] + "\n" + paragraph
            continue
        m = re.match(r"^(.+?) ((?:Tiny|Small|Medium|Large|Huge|Gargantuan|Huge or Smaller)\b.*?) AC (.+?) HP (.+?) Speed (.+)$", paragraph)
        if m:
            paragraph = "\n".join([m.group(1), m.group(2), f"AC {m.group(3)}", f"HP {m.group(4)}", f"Speed {m.group(5)}"])
        else:
            for section in SECTIONS:
                if paragraph.startswith(section + " ") and not paragraph.startswith(section + " of"):
                    paragraph = section + "\n" + paragraph[len(section) + 1:]
                    break
        out.append(paragraph)
    return "\n\n".join(out)


def split_bullets(text):
    """Bullet items the PDFs run together ("- Weal, … - Woe, …") become one
    line each."""
    lines = []
    for line in text.split("\n"):
        if line.startswith("- ") and " - " in line:
            lines.extend("- " + item for item in re.split(r" - (?=[A-Za-z0-9{])", line[2:]))
        else:
            lines.append(line)
    return "\n".join(lines)


# After a bullet list, the next sentence often stays on the last item's line.
LIST_ENDS = {
    "5.1": {
        "Augury": "good or bad",
        "Conjure Animals": "rating 1/4 or lower",
        "Conjure Minor Elementals": "rating 1/4 or lower.",
        "Conjure Woodland Beings": "rating 1/4 or lower",
        "Commune with Nature": "- buildings",
        "Divine Word": "killed instantly",
    },
    "5.2.1": {"Commune with Nature": "- Locations of bodies of water"},
}


def apply(pack, name, text):
    text = split_bullets(text)
    if end := LIST_ENDS.get(pack, {}).get(name):
        at = text.index(end) + len(end)
        text = text[:at] + "\n\n" + text[at:].lstrip()
    for old, new in FIXES.get(pack, {}).get(name, []):
        if isinstance(old, re.Pattern):
            text, count = old.subn(lambda _: new, text)
        else:
            count = text.count(old)
            text = text.replace(old, new)
        if count != 1 and not (isinstance(old, str) and old.startswith("\n\n- ")):
            raise ValueError(f"layout fix did not apply once: {str(old)[:50]!r} ({count})")
    if "MOD SAVE" in text:
        text = format_stat_block(text)
    return text
