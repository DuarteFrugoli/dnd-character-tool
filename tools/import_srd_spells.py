"""Replace spell descriptions with the official text of the SRD PDFs.

Reads every spell of the pack's spells.json from the PDF and rewrites its
`description` and `higherLevels` with the official text, with measures written
as markers (see tools/srd_markup.py). Every other field is kept.

Examples:
  python tools/import_srd_spells.py --pack 5.2.1 --pdf docs/private/SRD_CC_v5.2.1.pdf --dry-run
  python tools/import_srd_spells.py --pack 5.1 --pdf docs/private/SRD-OGL_V5.1.pdf

Requires `pdftotext` (Poppler). The tool reads a local copy of the official
PDF and never fetches anything. Spells listed in OVERRIDES keep hand-written
text where the PDF layout (tables, stat blocks) does not extract cleanly.
"""

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import srd_spell_tables  # noqa: E402
from srd_markup import to_markers, render_imperial  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
PARAGRAPH = "¶"
EDITIONS = {"5.1": "2014", "5.2.1": "2024"}
HEADERS = {
    "2014": re.compile(r"^(?:\d(?:st|nd|rd|th)-+level [a-z]+(?: \(ritual\))?|[A-Za-z]+ cantrip)\b"),
    "2024": re.compile(r"^(?:Level \d [A-Z][a-z]+|[A-Z][a-z]+ Cantrip) \("),
}
# The app keeps the Player's Handbook names; the 5.1 SRD drops the wizards'
# names from them.
SRD_NAMES = {
    "Nystul's Magic Aura": "Arcanist's Magic Aura",
    "Leomund's Tiny Hut": "Tiny Hut",
    "Evard's Black Tentacles": "Black Tentacles",
    "Mordenkainen's Faithful Hound": "Faithful Hound",
    "Mordenkainen's Private Sanctum": "Private Sanctum",
    "Otiluke's Resilient Sphere": "Resilient Sphere",
    "Bigby's Hand": "Arcane Hand",
    "Rary's Telepathic Bond": "Telepathic Bond",
    "Drawmij's Instant Summons": "Instant Summons",
    "Mordenkainen's Magnificent Mansion": "Magnificent Mansion",
    "Mordenkainen's Sword": "Arcane Sword",
}
# Chapters that follow the spells.
CHAPTER_ENDS = {"Traps", "Rules Glossary"}
HIGHER = {"2014": "At Higher Levels.", "2024": "Using a Higher-Level Spell Slot."}
FOOTER = re.compile(
    r"Not for resale\. Permission granted to print or photocopy this document for personal use only\."
    r"|\d*\s*System Reference Document 5\.[12](?:\.1)?\s*\d*|^\s*\d{1,3}\s*$"
)
# Words after "--" that show an em dash in the 2014 PDF, which writes both
# hyphens and dashes as "--".
DASH_WORDS = {
    "including", "look", "and", "or", "the", "a", "an", "that", "which", "as", "such", "even",
    "but", "if", "not", "with", "for", "from", "until", "unless",
    "except", "whether", "so", "then", "though", "this", "these", "those", "its", "their",
    "your", "you", "it", "they", "he", "she", "we", "all", "any", "each", "no",
}


def extract(pdf):
    with tempfile.TemporaryDirectory() as folder:
        output = Path(folder) / "srd.txt"
        subprocess.run(["pdftotext", str(pdf), str(output)], check=True, capture_output=True)
        return output.read_bytes().decode("utf-8", "replace")


def dashes_2014(text):
    """The 2014 PDF writes hyphens and em dashes as "--"."""
    def repl(m):
        word = m.group(1).lower()
        return "—" if word in DASH_WORDS else "-"
    return re.sub(r"(?<=\w)--\s*(?=([A-Za-z]+|\d))", repl, text)


def clean_lines(text, edition):
    text = text.replace("\r\n", "\n")
    if edition == "2014":
        text = re.sub(r"[ \r]{6,}", f" {PARAGRAPH} ", text).replace("\r", " ")
    lines = []
    for line in text.split("\n"):
        line = line.replace("\x0c", " ")
        if FOOTER.search(line):
            line = FOOTER.sub(" ", line)
            if not line.strip(f" {PARAGRAPH}"):
                continue
        lines.append(re.sub(r"[ \t\x0c]+", " ", line).strip())
    return lines


def spell_blocks(lines, names, edition):
    """Maps spell name to the lines from its header to the next spell header
    of the PDF, and lists the PDF spells the catalog does not have."""
    header = HEADERS[edition]
    wanted = {SRD_NAMES.get(name, name).lower(): name for name in names}
    starts = []
    for i, line in enumerate(lines[:-1]):
        title = line.strip(f" {PARAGRAPH}")
        if not title or len(title) > 40:
            continue
        following = next((l for l in lines[i + 1:i + 3] if l.strip(f" {PARAGRAPH}")), "")
        if header.match(following.strip(f" {PARAGRAPH}")):
            starts.append((i, title))
    blocks = {}
    for n, (i, title) in enumerate(starts):
        end = starts[n + 1][0] if n + 1 < len(starts) else len(lines)
        chapter = next((j for j in range(i + 1, end) if lines[j].strip(f" {PARAGRAPH}") in CHAPTER_ENDS), None)
        blocks[wanted.get(title.lower(), title)] = lines[i + 1:chapter or end]
    unknown = sorted(title for title in blocks if title not in names)
    return blocks, unknown


def squash(text):
    return re.sub(r"[^a-z0-9]", "", text.lower())


def join_hyphenated(text, vocabulary):
    """Joins words split at line ends ("addi- tional") when the joined word
    appears elsewhere in the PDF; real hyphens ("well- known") stay."""
    def repl(m):
        joined = m.group(1) + m.group(2)
        return joined if joined.lower() in vocabulary else f"{m.group(1)}-{m.group(2)}"
    return re.sub(r"\b([A-Za-z]+)- ([a-z]+)\b", repl, text)


def body(block, spell, edition, vocabulary):
    """The description text after the Duration line, with paragraphs."""
    text = "\n".join(block)
    at = text.find("Duration:")
    if at < 0:
        raise ValueError("no Duration")
    rest = text[at + len("Duration:"):]
    # The catalog may leave out "Concentration, up to" from the duration.
    want = squash(spell["duration"])
    consumed = ""
    i = 0
    while i < len(rest) and not squash(consumed).endswith(want) and len(squash(consumed)) < len(want) + 20:
        consumed += rest[i]
        i += 1
    if not squash(consumed).endswith(want):
        i = rest.find("\n") + 1
    # The duration may end with a period ("Up to 1 hour.").
    while i < len(rest) and rest[i] in " .\n":
        i += 1
    rest = rest[i:]
    if edition == "2014":
        # Lines are layout breaks; paragraphs are marked.
        flat = re.sub(r"\s+", " ", rest.replace("\n", " "))
        # Page footers can be split over lines.
        flat = re.sub(
            r"Not for resale\. Permission granted to print or photocopy this document for personal use only\."
            r"\s*(?:" + PARAGRAPH + r"\s*)?System Reference Document 5\.1\s*\d*",
            " ",
            flat,
        )
        paragraphs = [p.strip() for p in flat.split(PARAGRAPH)]
    else:
        paragraphs = []
        for line in rest.split("\n"):
            line = line.strip()
            if not line:
                continue
            if paragraphs and (not re.search(r"[.:!?\")]$", paragraphs[-1]) or line[0].islower()):
                paragraphs[-1] += " " + line
            else:
                paragraphs.append(line)
    paragraphs = [p for p in paragraphs if p]
    text = "\n\n".join(paragraphs)
    # The PDFs lose "×" ("1d4 × 10 minutes") to an unknown character, which
    # the 2014 PDF also uses for em dashes ("wall—up to 90 feet long").
    text = re.sub(r"(\d+d\d+)\s*�\s*(?=\d)", "\\1 × ", text)
    if edition == "2014":
        # Bullets: one item per line.
        text = re.sub(r"(?<=[.:]) ?� ", "\n- ", text)
        text = re.sub(r"(?<=\w)�(?=by\b)", "-", text)
        text = re.sub(r"(?<=[a-z])�(?=[a-z])", "—", text)
        text = re.sub(r"(?<=\d) ?� ?(?=\d)", "-", text)
    text = text.replace("−", "-").replace("–", "-").replace("�", "-")
    text = text.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"')
    if edition == "2014":
        text = dashes_2014(text)
    else:
        # The 2024 PDF writes em dashes as "--", sometimes before a line break.
        text = re.sub(r"(?<=\w)--\s?(?=\w)", "—", text)
        # It also drops hyphens at line breaks: "10foot", "40-foothigh", "by10-foot".
        text = re.sub(r"(\d)(foot|feet)\b", r"\1-\2", text)
        text = re.sub(r"(\d-foot)(high|by|wide|long|tall|deep|thick)\b", r"\1-\2", text)
        text = re.sub(r"\bby(\d)", r"by-\1", text)
    text = join_hyphenated(text, vocabulary)
    text = re.sub(r" +([.,;:])", r"\1", text)
    return re.sub(r"[ \t]+", " ", text).strip()


def split_higher(text, edition):
    """Moves the higher-level text to its own field; "Cantrip Upgrade." starts
    its own paragraph even when the PDF ran it into the previous one."""
    text = re.sub(r"(?<=[.)]) (Cantrip Upgrade\.)", r"\n\n\1", text)
    label = HIGHER[edition]
    at = text.rfind(label)
    if at < 0:
        return text, None
    end = text.find("\n\n", at)
    higher = text[at + len(label):end if end > 0 else len(text)].strip()
    rest = (text[:at].rstrip() + ("\n\n" + text[end + 2:] if end > 0 else "")).strip()
    return rest, higher


# A run-in heading ("False Aura. You change…") after a sentence starts a
# paragraph; the PDFs lose the break when it falls on a page or column break.
RUN_IN_HEADING = re.compile(
    r"(?<![0-9]\.)(?<=[.)\]]) ((?:[A-Z][A-Za-z'-]*)(?: (?:[A-Z][A-Za-z'-]*|of|the|and|or|with|to|in|a))*"
    r"(?: \([^)]{1,30}\))?\. )(?=[A-Z])"
)


def import_spells(pack, pdf):
    edition = EDITIONS[pack]
    path = ROOT / "assets" / "data" / "srd" / pack / "spells.json"
    spells = json.loads(path.read_text(encoding="utf-8"))
    raw = extract(pdf)
    vocabulary = set(re.findall(r"[a-z]+", raw.lower()))
    lines = clean_lines(raw, edition)
    blocks, unknown = spell_blocks(lines, [s["name"] for s in spells], edition)
    results = {}
    problems = [f"{title}: in the PDF but not in spells.json" for title in unknown]
    for spell in spells:
        block = blocks.get(spell["name"])
        if block is None:
            problems.append(f"{spell['name']}: not found in the PDF")
            continue
        try:
            text = body(block, spell, edition, vocabulary)
            text = srd_spell_tables.apply(pack, spell["name"], text)
            text = RUN_IN_HEADING.sub(lambda m: "\n\n" + m.group(1), text)
        except ValueError as error:
            problems.append(f"{spell['name']}: {error}")
            continue
        description, higher = split_higher(text, edition)
        results[spell["name"]] = (description, higher)
    return path, spells, results, problems


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--pack", choices=tuple(EDITIONS), required=True)
    parser.add_argument("--pdf", type=Path, required=True)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--dump", type=Path, help="write the extracted plain text as JSON for review")
    args = parser.parse_args()
    path, spells, results, problems = import_spells(args.pack, args.pdf)
    if args.dump:
        args.dump.write_text(json.dumps(results, ensure_ascii=False, indent=1), encoding="utf-8")
    failed_round_trip = []
    for spell in spells:
        if spell["name"] not in results:
            continue
        description, higher = results[spell["name"]]
        for value in (description, higher):
            # "half a mile" comes back as "1/2 mile", "10 additional gallons" as
            # "an additional 10 gallons".
            expected = value and re.sub(
                r"(\d+) additional gallons", r"an additional \1 gallons",
                value.replace("half-mile", "1/2-mile").replace("half a mile", "1/2 mile"),
            )
            if value is not None and render_imperial(to_markers(value)) != expected:
                failed_round_trip.append(spell["name"])
        spell["description"] = to_markers(description)
        spell["higherLevels"] = to_markers(higher) if higher else None
    raw = path.read_text(encoding="utf-8")
    if raw.startswith("[\n  {\n"):
        # Pretty-printed with an indent of two.
        output = json.dumps(spells, indent=2, ensure_ascii=False) + "\n"
    else:
        # One spell per line.
        compact = '{"name":' in raw[:200]
        separators = (",", ":") if compact else (", ", ": ")
        rows = [json.dumps(spell, ensure_ascii=False, separators=separators) for spell in spells]
        output = "[\n" + ",\n".join(f"  {row}" for row in rows) + "\n]" + ("\n" if raw.endswith("\n") else "")
    for problem in problems + [f"{name}: markers do not round-trip" for name in failed_round_trip]:
        print(problem)
    print(f"SRD {args.pack}: {len(results)}/{len(spells)} spells read from the PDF")
    if not args.dry_run:
        path.write_text(output, encoding="utf-8")


if __name__ == "__main__":
    main()
