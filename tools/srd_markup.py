"""Writes the measures of English SRD text as markers, and back.

`to_markers` turns "within 30 feet", "a 10-foot cube", "range 20/60 ft.",
"40 gallons" or "2,500 square feet" into the markers rendered by
lib/core/units/measure_markup.dart. `render_imperial` renders markers back
to English imperial text, so importers can check that only the markup
changed.
"""

import re

NUMBER = r"\d{1,3}(?:,\d{3})+|\d+(?:\.\d+)?"
LEAD = r"(?<![\w.,/+\-])"
FRACTIONS = {"1/2": "0.5", "1/4": "0.25", "3/4": "0.75", "1/5": "0.2"}
SHOWN_FRACTIONS = {0.2: "1/5", 0.25: "1/4", 0.5: "1/2", 0.75: "3/4"}

DISTANCE_WORDS = {
    "ft": ("foot", "feet", "ft."),
    "in": ("inch", "inches", "in."),
    "mi": ("mile", "miles", "mi."),
}
MEASURE_WORDS = {
    "sqft": ("square foot", "square feet"),
    "sqmi": ("square mile", "square miles"),
    "cuft": ("cubic foot", "cubic feet"),
    "cuin": ("cubic inch", "cubic inches"),
    "gal": ("gallon", "gallons"),
    "pint": ("pint", "pints"),
    "floz": ("ounce", "ounces"),
}
KIND = {"ft": "distance", "in": "distance", "mi": "distance", "sqft": "area", "sqmi": "area"}


def _value(text):
    text = text.replace(",", "")
    return FRACTIONS.get(text, text)


def to_markers(text):
    """English text with its measures written as markers."""
    if text is None:
        return None
    # "10 additional gallons" reads "an additional 40 liters" in metric.
    text = re.sub(rf"{LEAD}(\d+) additional gallons\b", r"an additional {{volume:\1gal}}", text)
    # Areas and volumes first: "40 square feet" must not become a distance.
    for unit, (one, many) in MEASURE_WORDS.items():
        kind = KIND.get(unit, "volume")
        words = rf"(?:{one}|{many})".replace(" ", "[ -]")
        number = rf"{LEAD}({NUMBER}|1/[245]|3/4)"
        if unit == "floz":
            # Only "4-ounce vial": other ounces are weights.
            text = re.sub(rf"{LEAD}(\d+)-ounce\b", rf"{{{{volume:\1floz|adj}}}}", text)
            continue
        text = re.sub(rf"{number}[ -]{words}\b",
                      lambda m: f"{{{{{kind}:{_value(m.group(1))}{unit}}}}}", text)
        if unit in ("cuft", "cuin"):
            text = re.sub(rf"\b(?:a|one) {words}\b", f"{{{{{kind}:1{unit}}}}}", text)
            text = re.sub(rf"\bhalf a {words}\b", f"{{{{{kind}:0.5{unit}}}}}", text)
    # "10-foot-by-20-foot panels": both sides are distances.
    text = re.sub(r"(?<=-foot-by-)(\d+)-foot\b", r"{{distance:\1ft|adj}}", text)
    text = re.sub(r"\bhalf a mile\b", "{{distance:0.5mi}}", text)
    text = re.sub(r"\bhalf-mile\b", "{{distance:0.5mi|adj}}", text)
    for unit, (one, many, short) in DISTANCE_WORDS.items():
        number = rf"{LEAD}((?:{NUMBER})(?:/(?:{NUMBER}))?|1/[245]|3/4)(\+)?"
        text = re.sub(rf"{number}-{one}\b", lambda m: _marker(m, unit, "adj"), text)
        text = re.sub(rf"{number} {re.escape(short)}(?=[\s,;:)]|$)", lambda m: _marker(m, unit, "short"), text)
        text = re.sub(rf"{number} (?:{one}|{many})\b", lambda m: _marker(m, unit, ""), text)
    # "11 to 20 ft." and "30, 60, and 120 feet": the unit follows the last.
    target = r"(?=\{\{distance:[\d.]+(ft|in|mi)(?:\|short)?\}\})"
    text = re.sub(rf"{LEAD}({NUMBER})( to | or | and |, or |, and |-by-| by ){target}",
                  lambda m: f"{{{{distance:{_value(m.group(1))}{m.group(3)}|num}}}}{m.group(2)}", text)
    chain = re.compile(rf"{LEAD}({NUMBER})(, |-by-)(?=\{{\{{distance:[\d.]+(ft|in|mi)\|num\}}\}})")
    while chain.search(text):
        text = chain.sub(lambda m: f"{{{{distance:{_value(m.group(1))}{m.group(3)}|num}}}}{m.group(2)}", text)
    return text


def _marker(m, unit, form):
    value = m.group(1)
    if "/" in value and value in FRACTIONS:
        value = FRACTIONS[value]
    else:
        value = value.replace(",", "")
    plus = "+" if m.group(2) else ""
    return f"{{{{distance:{value}{plus}{unit}{'|' + form if form else ''}}}}}"


MARKER = re.compile(r"\{\{(distance|area|volume):([\d.]+)(?:/([\d.]+))?(\+)?([a-z]+)(?:\|([a-z]+))?\}\}")


def _number(value):
    v = float(value)
    if v in SHOWN_FRACTIONS:
        return SHOWN_FRACTIONS[v], True
    whole = int(v)
    if v == whole:
        return f"{whole:,}", False
    return f"{v:g}", False


def render_imperial(text):
    """Markers rendered as English imperial text."""
    if text is None:
        return None

    def render(m):
        kind, first, second, plus, unit, form = m.groups()
        parts = [_number(first)] + ([_number(second)] if second else [])
        number = "/".join(p[0] for p in parts) + (plus or "")
        if form == "num":
            return number
        last = float(second or first)
        singular = last == 1 or parts[-1][1]
        if unit in DISTANCE_WORDS:
            one, many, short = DISTANCE_WORDS[unit]
        else:
            one, many = MEASURE_WORDS[unit]
            short = many
        if form == "adj":
            return f"{number}-{one}"
        if form == "short":
            return f"{number} {short}"
        return f"{number} {one if singular else many}"

    return MARKER.sub(render, text)
