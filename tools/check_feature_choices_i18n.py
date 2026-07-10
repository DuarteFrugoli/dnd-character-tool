"""Validate feature_choices i18n overlays against SRD descriptions."""

from __future__ import annotations

import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRD_FILE = ROOT / "assets" / "data" / "srd" / "feature_choices.json"
I18N_DIR = ROOT / "assets" / "data" / "i18n"


def _load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _description_paths(source: dict) -> list[tuple[str, ...]]:
    paths: list[tuple[str, ...]] = []

    for source_name, options in source.get("optionSources", {}).items():
        for option in options:
            if "description" in option:
                paths.append(("optionSources", source_name, option["id"]))

    for class_name, features in source.get("classFeatures", {}).items():
        for feature_name, definition in features.items():
            for choice in definition.get("choices", []):
                for option in choice.get("options", []):
                    if "description" in option:
                        paths.append((
                            "classFeatures",
                            class_name,
                            feature_name,
                            "choices",
                            choice["id"],
                            "options",
                            option["id"],
                        ))

    for class_name, subclasses in source.get("subclassFeatures", {}).items():
        for subclass_name, features in subclasses.items():
            for feature_name, definition in features.items():
                for choice in definition.get("choices", []):
                    for option in choice.get("options", []):
                        if "description" in option:
                            paths.append((
                                "subclassFeatures",
                                class_name,
                                subclass_name,
                                feature_name,
                                "choices",
                                choice["id"],
                                "options",
                                option["id"],
                            ))

    for root_name in ("raceTraits", "feats"):
        for feature_name, definition in source.get(root_name, {}).items():
            for choice in definition.get("choices", []):
                for option in choice.get("options", []):
                    if "description" in option:
                        paths.append((
                            root_name,
                            feature_name,
                            "choices",
                            choice["id"],
                            "options",
                            option["id"],
                        ))

    return paths


def _has_description(overlay: dict, path: tuple[str, ...]) -> bool:
    current: object = overlay
    for part in path:
        if not isinstance(current, dict) or part not in current:
            return False
        current = current[part]
    return isinstance(current, dict) and "description" in current


def main() -> int:
    source = _load_json(SRD_FILE)
    paths = _description_paths(source)
    failed = False

    for locale_dir in sorted(I18N_DIR.iterdir()):
        if not locale_dir.is_dir():
            continue
        overlay_file = locale_dir / "feature_choices.json"
        if not overlay_file.exists():
            print(f"{locale_dir.name}: missing feature_choices.json")
            failed = True
            continue

        overlay = _load_json(overlay_file)
        missing = [path for path in paths if not _has_description(overlay, path)]
        print(f"{locale_dir.name}: {len(missing)} missing descriptions")
        if missing:
            failed = True
            for path in missing[:10]:
                print("  - " + "/".join(path))
            if len(missing) > 10:
                print(f"  ... {len(missing) - 10} more")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
