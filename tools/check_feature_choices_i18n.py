"""Compatibility entry point for validating 5.1 feature-choice translations."""

import sys

from check_srd_i18n import main


if __name__ == "__main__":
    sys.argv = [sys.argv[0], "--pack", "5.1", "--file", "feature_choices.json", *sys.argv[1:]]
    raise SystemExit(main())
