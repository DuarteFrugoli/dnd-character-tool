"""Convert SRD stat blocks from the official PDFs into the app's monster catalog.

The catalog currently holds the Beasts that Wild Shape can use (CR 1 or lower),
but every stat block keeps the full structure a future tabletop needs: sizes,
type, armor class, hit points, speeds, abilities, saves, skills, defenses,
senses, languages, challenge, and traits/actions with structured attacks,
damage, saving throws, and recharges.

Examples:
  python tools/import_srd_monsters.py --pack 5.2.1 --pdf docs/private/SRD_CC_v5.2.1.pdf
  python tools/import_srd_monsters.py --pack 5.1 --pdf docs/private/SRD-OGL_V5.1.pdf --dry-run

Requires `pdftotext` (Poppler). The tool reads the PDF named in the pack
manifest from a local copy and never fetches anything.
"""

import argparse
import json
import re
import subprocess
import sys
import tempfile
from fractions import Fraction
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent

# Pages that hold stat blocks: 5.1 "Monsters" and "Appendix MM-A"; 5.2.1
# "Animals" (its "Monsters A-Z" has no Beast stat blocks).
PACKS = {
    "5.1": {"edition": "2014", "pages": (250, 394), "start": None},
    "5.2.1": {"edition": "2024", "pages": (343, 364), "start": "Animals"},
}

SIZES = "Tiny|Small|Medium|Large|Huge|Gargantuan"
ABILITIES = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]
SHORT = ["Str", "Dex", "Con", "Int", "Wis", "Cha"]
SKILL_ABILITY = {
    "acrobatics": "dexterity", "animal handling": "wisdom", "arcana": "intelligence",
    "athletics": "strength", "deception": "charisma", "history": "intelligence",
    "insight": "wisdom", "intimidation": "charisma", "investigation": "intelligence",
    "medicine": "wisdom", "nature": "intelligence", "perception": "wisdom",
    "performance": "charisma", "persuasion": "charisma", "religion": "intelligence",
    "sleight of hand": "dexterity", "stealth": "dexterity", "survival": "wisdom",
}
DAMAGE_TYPES = {
    "acid", "bludgeoning", "cold", "fire", "force", "lightning", "necrotic",
    "piercing", "poison", "psychic", "radiant", "slashing", "thunder",
}
SECTIONS = {
    "Traits": "traits",
    "Actions": "actions",
    "Bonus Actions": "bonusActions",
    "Reactions": "reactions",
    "Legendary Actions": "legendaryActions",
}
PARAGRAPH = "¶"
DAMAGE_TERM = r"(\d+)(?: \(([\dd+\- ]+)\))? (\w+) damage"
HEADER = re.compile(
    rf"^({SIZES})(?: or ({SIZES}))? (?:(swarm) of ({SIZES}) )?(\w+?)s?(?: \(([^)]+)\))?, (.+)$",
    re.I,
)
ENTRY = re.compile(
    r"(?:(?<=\s)|^)((?:[A-Z][\w'-]*)(?: (?:[A-Z][\w'-]*|of|the|and|or|to|in|with|a))*"
    r"(?: \((?:Recharge [\d\-]+|\d+/Day(?: Each)?|Costs \d+ Actions"
    r"|Recharges after a Short or Long Rest|[^)]{1,40})\))?)\. (?=[A-Z])"
)


def normalize(text, edition):
    text = text.replace("−", "-").replace("–", "-").replace("�", "-")
    text = text.replace("’", "'").replace("“", '"').replace("”", '"')
    text = text.replace("—", " - " if edition == "2014" else "—")
    if edition == "2024":
        # The 2024 PDF writes em dashes as "--".
        text = re.sub(r"(?<=\w)--(?=\w)", "—", text)
    return re.sub(r"[ \t\x0c]+", " ", text)


def slug(name):
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


def challenge_value(rating):
    return float(Fraction(rating))


def dice_average(formula):
    total = 0
    for sign, count, sides, flat in re.findall(r"([+-]?)(?:(\d+)d(\d+)|(\d+))", formula):
        value = int(count) * (int(sides) + 1) / 2 if sides else int(flat)
        total += -value if sign == "-" else value
    return int(total)


def modifier(score):
    return (score - 10) // 2


def proficiency_for_challenge(rating):
    value = challenge_value(rating)
    return 2 if value < 1 else 2 + (int(value) - 1) // 4


def parse_speed(text):
    speed = {}
    choice = re.search(r"(\w+) or (\w+) (\d+) ft\.? \(GM's choice\)", text)
    if choice:
        speed[choice.group(1).lower()] = speed[choice.group(2).lower()] = int(choice.group(3))
        speed["oneOf"] = [choice.group(1).lower(), choice.group(2).lower()]
        text = text[:choice.start()] + text[choice.end():]
    for part in [p.strip() for p in text.split(",") if p.strip()]:
        m = re.match(r"(?:(Walk|Burrow|Climb|Fly|Swim)\s+)?(\d+) ft\.?(\s*\(hover\))?$", part, re.I)
        if not m:
            raise ValueError(f"speed: {text!r}")
        speed[(m.group(1) or "walk").lower()] = int(m.group(2))
        if m.group(3):
            speed["hover"] = True
    return speed


def parse_senses(text):
    senses = {}
    for part in [p.strip() for p in re.split(r"[,;]", text) if p.strip()]:
        m = re.match(r"(Blindsight|Darkvision|Tremorsense|Truesight) (\d+) ft\.?", part, re.I)
        if m:
            senses[m.group(1).lower()] = int(m.group(2))
            continue
        m = re.match(r"passive Perception (\d+)$", part, re.I)
        if not m:
            raise ValueError(f"senses: {text!r}")
        senses["passivePerception"] = int(m.group(1))
    return senses


def parse_bonus_list(text):
    result = {}
    for part in [p.strip() for p in text.split(",") if p.strip()]:
        m = re.match(r"(.+?) ([+-]\d+)$", part)
        if not m:
            raise ValueError(f"bonus list: {text!r}")
        result[m.group(1).strip().lower()] = int(m.group(2))
    return result


def damage_term(groups):
    average, formula, damage_type = groups
    return {
        "average": int(average),
        "formula": (formula or average).replace(" ", ""),
        "type": damage_type.lower(),
    }


def parse_hit_damage(text):
    """Damage of a hit: the first term and the ones chained with "plus"."""
    text = re.sub(r"—or .*?—", " ", text.strip())
    damage = []
    m = re.match(DAMAGE_TERM, text, re.I)
    while m:
        damage.append(damage_term(m.groups()))
        m = re.compile(r"\s*plus " + DAMAGE_TERM, re.I).match(text, m.end())
    return damage


def split_entries(text):
    """Splits a section body into `Name. description` entries."""
    starts = [
        (m.start(1), m.end(), m.group(1))
        for m in ENTRY.finditer(text)
        if m.start(1) == 0 or text[:m.start(1)].rstrip().endswith((".", ":"))
    ]
    return [
        {"name": name.strip(), "description": text[body:starts[i + 1][0] if i + 1 < len(starts) else len(text)].strip()}
        for i, (_, body, name) in enumerate(starts)
    ]


def parse_entry(entry, edition):
    name, description = entry["name"], entry["description"]
    usage = None
    m = re.match(r"(.+?) \((Recharge [\d\-]+|\d+/Day(?: Each)?|Recharges after a Short or Long Rest)\)$", name)
    if m:
        name, usage = m.group(1), m.group(2)
    out = {"id": slug(name), "name": name, "description": description}
    if usage:
        recharge = re.match(r"Recharge (\d+)", usage)
        if recharge:
            out["usage"] = {"type": "recharge", "min": int(recharge.group(1))}
        elif "Day" in usage:
            out["usage"] = {"type": "per_day", "uses": int(usage.split("/")[0])}
        else:
            out["usage"] = {"type": "per_rest", "rest": "short_or_long_rest"}
    attack_pattern = (
        r"(Melee|Ranged|Melee or Ranged) Attack Roll: ([+-]\d+)(?: \([^)]*\))?, (.+?)\. Hit: (.*)"
        if edition == "2024"
        else r"(Melee|Ranged|Melee or Ranged) Weapon Attack: ([+-]\d+) to hit, (.+?)\. Hit: (.*)"
    )
    a = re.match(attack_pattern, description)
    if a:
        attack = {"kind": a.group(1).lower().replace(" or ", "_or_"), "bonus": int(a.group(2))}
        reach = re.search(r"reach (\d+) (?:ft|feet)", a.group(3))
        distance = re.search(r"range (\d+)(?:/(\d+))? (?:ft|feet)", a.group(3))
        if reach:
            attack["reach"] = int(reach.group(1))
        if distance:
            attack["range"] = {"normal": int(distance.group(1))}
            if distance.group(2):
                attack["range"]["long"] = int(distance.group(2))
        out["attack"] = attack
        damage = parse_hit_damage(a.group(4))
        if damage:
            out["damage"] = damage
    save = re.search(r"(Strength|Dexterity|Constitution|Intelligence|Wisdom|Charisma) Saving Throw: DC (\d+)", description)
    if save:
        ability, dc = save.groups()
    else:
        save = re.search(r"DC (\d+) (Strength|Dexterity|Constitution|Intelligence|Wisdom|Charisma) saving throw", description)
        if save:
            dc, ability = save.groups()
    if save:
        out["save"] = {"ability": ability.lower(), "dc": int(dc)}
        after = description[save.end():]
        failed = re.search(r"(?:taking|Failure:) " + DAMAGE_TERM, after, re.I)
        if failed:
            out["save"]["damage"] = [damage_term(failed.groups())]
            if re.search(r"half as much damage|Success: Half damage", after, re.I):
                out["save"]["halfOnSuccess"] = True
    return out


def stat_blocks(text, edition):
    """Yields (name line, header line, body) for every stat block."""
    if edition == "2014":
        # Wide gaps mark paragraph breaks; flavor text after a stat block
        # starts a paragraph that is not a "Name." entry.
        text = text.replace("\r\n", "\n")
        text = re.sub(r"[ \r]{6,}", f" {PARAGRAPH} ", text).replace("\r", " ")
        text = re.sub(r"(?<=\w)--\s*(?=\w)", "-", text)
    raw = [normalize(line, edition).strip() for line in text.split("\n")]
    raw = [
        line for line in raw
        if line.strip(f"{PARAGRAPH} ")
        and not re.search(r"System Reference Document 5\.|Not for resale", line)
        and not re.fullmatch(r"\d{3}", line.strip(f"{PARAGRAPH} "))
    ]
    # Paragraph marks stay in the body (a break can end a line) but not in
    # the name and header lines.
    lines = [line.strip(f"{PARAGRAPH} ") for line in raw]
    found = [i for i, line in enumerate(lines) if i > 0 and HEADER.match(line)]
    for n, i in enumerate(found):
        end = found[n + 1] - 1 if n + 1 < len(found) else len(lines)
        yield lines[i - 1], lines[i], " ".join(raw[i + 1:end])


def without_marks_before(text, pattern):
    """Drops paragraph marks up to the end of [pattern]."""
    plain = text.replace(f" {PARAGRAPH}", "")
    m = re.search(pattern, plain)
    if not m:
        return text
    index = consumed = 0
    while consumed < m.end():
        if text.startswith(f" {PARAGRAPH}", index):
            index += 2
        else:
            index += 1
            consumed += 1
    return plain[:m.end()] + text[index:]


def parse_abilities_2024(text):
    region = text[:re.search(r" (?:Skills|Senses|Resistances|Immunities|Vulnerabilities|Gear) ", text).start()]
    region = re.sub(r"Initiative [+-]\d+ \(\d+\)", "", region).replace("MOD SAVE", " ")
    abilities, saves, orphans = {}, {}, []
    for short, ability in zip(SHORT, ABILITIES):
        m = re.search(rf"{short} (\d+)(?: ([+-]\d+) ([+-]\d+))?", region)
        abilities[ability] = int(m.group(1))
        if m.group(2):
            if m.group(3) != m.group(2):
                saves[ability] = int(m.group(3))
        else:
            # Narrow stat blocks print some modifiers on a later line.
            orphans.append((m.start(), ability))
        region = region[:m.start()] + " " * (m.end() - m.start()) + region[m.end():]
    loose = [int(v) for v in re.findall(r"(?<![\w(])([+-]\d+)(?![\w)])", region)]
    if len(loose) != 2 * len(orphans):
        raise ValueError(f"loose ability values {loose} for {orphans}")
    for k, (_, ability) in enumerate(sorted(orphans)):
        if loose[2 * k] != modifier(abilities[ability]):
            raise ValueError(f"modifier mismatch for {ability}")
        if loose[2 * k + 1] != loose[2 * k]:
            saves[ability] = loose[2 * k + 1]
    return abilities, saves


def parse_abilities_2014(text):
    m = re.search(r"STR DEX CON INT WIS CHA " + " ".join([r"(\d+) \(([+-]\d+)\)"] * 6), text)
    abilities = {ability: int(m.group(1 + 2 * k)) for k, ability in enumerate(ABILITIES)}
    saves = {}
    listed = re.search(r"Saving Throws (.+?)(?= Skills| Damage| Condition| Senses)", text)
    if listed:
        by_short = {short.lower(): ability for short, ability in zip(SHORT, ABILITIES)}
        for part in listed.group(1).split(","):
            short, value = part.strip().rsplit(" ", 1)
            saves[by_short[short.lower()[:3]]] = int(value)
    return abilities, saves


FIELD_LABELS = [
    "Skills", "Resistances", "Immunities", "Vulnerabilities", "Gear", "Senses", "Languages", "CR",
    "Damage Vulnerabilities", "Damage Resistances", "Damage Immunities", "Condition Immunities", "Challenge",
]


def field(meta, label):
    m = re.search(rf"(?<![A-Za-z]){label} (.+?)(?= (?:{'|'.join(FIELD_LABELS)}) |\s*$)", meta)
    return m.group(1).strip() if m else None


def split_list(value):
    return [v.strip().lower() for v in re.split(r"[,;]", value) if v.strip()]


def parse_block(name, header, body, edition):
    h = HEADER.match(header)
    monster = {
        "id": slug(name),
        "name": name,
        "size": [h.group(1).lower()] + ([h.group(2).lower()] if h.group(2) else []),
        "type": h.group(5).lower(),
        "tags": [t.strip().lower() for t in h.group(6).split(",")] if h.group(6) else [],
        "alignment": h.group(7).strip().lower(),
    }
    if h.group(3):
        monster["swarm"] = {"memberSize": h.group(4).lower()}
    text = body
    if edition == "2024":
        ac = re.search(r"AC (\d+)", text)
        initiative = re.search(r"Initiative ([+-]\d+) \((\d+)\)", text)
        hp = re.search(r"HP (\d+) \(([^)]+)\)", text)
        speed = re.search(r"Speed (.+?)(?= Initiative| MOD| Str \d)", text)
        monster["armorClass"] = {"value": int(ac.group(1))}
        monster["initiative"] = {"modifier": int(initiative.group(1)), "score": int(initiative.group(2))}
        challenge = re.search(r"CR (\S+) \(XP ([\d,]+)(?:, or [\d,]+ in lair)?; PB \+(\d+)\)", text)
        abilities, saves = parse_abilities_2024(text)
    else:
        text = without_marks_before(text, r"Challenge \S+ \([\d,]+ XP\)")
        ac = re.search(r"Armor Class (\d+)(?: \(([^)]+)\))?", text)
        hp = re.search(r"Hit Points (\d+) \(([^)]+)\)", text)
        speed = re.search(r"Speed (.+?)(?= STR)", text)
        monster["armorClass"] = {"value": int(ac.group(1))}
        if ac.group(2):
            monster["armorClass"]["source"] = ac.group(2)
        challenge = re.search(r"Challenge (\S+) \(([\d,]+) XP\)", text)
        abilities, saves = parse_abilities_2014(text)
    monster["hitPoints"] = {"average": int(hp.group(1)), "formula": hp.group(2).replace(" ", "")}
    monster["speed"] = parse_speed(speed.group(1))
    monster["abilities"] = abilities
    if saves:
        monster["savingThrows"] = saves
    meta = text[:challenge.end()]
    skills = field(meta, "Skills")
    if skills:
        monster["skills"] = parse_bonus_list(skills)
    for key, labels in (
        ("damageVulnerabilities", ("Damage Vulnerabilities", "Vulnerabilities")),
        ("damageResistances", ("Damage Resistances", "Resistances")),
    ):
        value = next((field(meta, label) for label in labels if field(meta, label)), None)
        if value:
            monster[key] = split_list(value)
    immunities = field(meta, "Damage Immunities" if edition == "2014" else "Immunities")
    if immunities:
        values = split_list(immunities)
        if [v for v in values if v in DAMAGE_TYPES]:
            monster["damageImmunities"] = [v for v in values if v in DAMAGE_TYPES]
        if [v for v in values if v not in DAMAGE_TYPES]:
            monster["conditionImmunities"] = [v for v in values if v not in DAMAGE_TYPES]
    conditions = field(meta, "Condition Immunities") if edition == "2014" else None
    if conditions:
        monster["conditionImmunities"] = split_list(conditions)
    gear = field(meta, "Gear")
    if gear:
        monster["gear"] = [g.strip() for g in gear.split(",")]
    monster["senses"] = parse_senses(field(meta, "Senses") or "")
    languages = field(meta, "Languages") or ""
    monster["languages"] = [] if languages in ("-", "--", "None", "") else [languages]
    monster["challengeRating"] = challenge.group(1)
    monster["experience"] = int(challenge.group(2).replace(",", ""))
    monster["proficiencyBonus"] = (
        int(challenge.group(3)) if edition == "2024" else proficiency_for_challenge(challenge.group(1))
    )

    rest = text[challenge.end():].strip()
    if edition == "2014":
        kept = []
        for paragraph in (p.strip() for p in rest.split(PARAGRAPH)):
            if not paragraph:
                continue
            if kept and not re.match(r"(?:(?:Actions|Reactions|Legendary Actions) )?" + ENTRY.pattern, paragraph):
                break
            kept.append(paragraph)
        rest = " ".join(kept)
    padded = " " + rest
    titles = [
        (m.group(1), m.start(), m.end())
        for m in re.finditer(r"(?:^| )(Traits|Bonus Actions|Legendary Actions|Reactions|Actions)(?= [A-Z])", padded)
    ]
    bodies = {}
    leading = padded[:titles[0][1]].strip() if titles else rest
    if leading:
        bodies["traits"] = leading
    for k, (title, _, end) in enumerate(titles):
        stop = titles[k + 1][1] if k + 1 < len(titles) else len(padded)
        bodies[SECTIONS[title]] = padded[end:stop].strip()
    for key in SECTIONS.values():
        entries = split_entries(bodies.get(key, ""))
        if entries:
            monster[key] = [parse_entry(entry, edition) for entry in entries]
    return monster


def warnings(monster):
    """Differences from the usual math; the SRD has a few on purpose or by typo."""
    found = []
    scores = monster["abilities"]
    bonus = monster["proficiencyBonus"]
    if dice_average(monster["hitPoints"]["formula"]) != monster["hitPoints"]["average"]:
        found.append(f"hit points {monster['hitPoints']}")
    perception = monster.get("skills", {}).get("perception", modifier(scores["wisdom"]))
    if monster["senses"].get("passivePerception") not in (None, 10 + perception):
        found.append("passive Perception")
    for skill, value in monster.get("skills", {}).items():
        base = modifier(scores[SKILL_ABILITY[skill]])
        if value not in (base + bonus, base + 2 * bonus):
            found.append(f"skill {skill} {value:+d}")
    for action in monster.get("actions", []):
        attack = action.get("attack")
        if attack and attack["bonus"] not in (modifier(scores["strength"]) + bonus, modifier(scores["dexterity"]) + bonus):
            found.append(f"attack {action['name']} {attack['bonus']:+d}")
        for damage in action.get("damage", []):
            if dice_average(damage["formula"]) != damage["average"]:
                found.append(f"damage {action['name']} {damage}")
    return found


def extract(pdf, pack):
    config = PACKS[pack]
    first, last = config["pages"]
    with tempfile.TemporaryDirectory() as folder:
        output = Path(folder) / "stat_blocks.txt"
        subprocess.run(["pdftotext", "-f", str(first), "-l", str(last), str(pdf), str(output)], check=True)
        text = output.read_bytes().decode("utf-8", "replace")
    if config["start"]:
        text = text[re.search(rf"(?m)^{config['start']}\s*$", text).start():]
    return text


def build(text, edition, max_challenge):
    """Beasts up to [max_challenge] and the Beast stat blocks that failed to parse."""
    monsters, failures = [], []
    for name, header, body in stat_blocks(text, edition):
        if HEADER.match(header).group(5).lower() != "beast":
            continue
        try:
            monster = parse_block(name, header, body, edition)
        except (AttributeError, KeyError, ValueError) as error:
            failures.append((name, error))
            continue
        if challenge_value(monster["challengeRating"]) <= max_challenge:
            monsters.append(monster)
    return sorted(monsters, key=lambda m: m["name"]), failures


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--pack", choices=tuple(PACKS), required=True)
    parser.add_argument("--pdf", type=Path, required=True)
    parser.add_argument("--max-cr", type=Fraction, default=Fraction(1), help="highest challenge rating to keep")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    edition = PACKS[args.pack]["edition"]
    monsters, failures = build(extract(args.pdf, args.pack), edition, float(args.max_cr))
    for name, error in failures:
        print(f"failed: {name}: {error}", file=sys.stderr)
    for monster in monsters:
        for warning in warnings(monster):
            print(f"note: {monster['name']}: {warning} (kept as published)")
    print(f"SRD {args.pack}: {len(monsters)} Beasts up to CR {args.max_cr}")
    if failures:
        raise SystemExit(f"{len(failures)} Beast stat block(s) failed to parse")
    if args.dry_run:
        return
    target = ROOT / "assets" / "data" / "srd" / args.pack / "monsters.json"
    target.write_text(json.dumps(monsters, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {target.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
