#!/usr/bin/env python3
"""Name and icon branding only. Loop UI must not be patched."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--loop-root", required=False)
    parser.add_argument("--design-root", required=False)
    parser.parse_args()
    print(
        "Skipping Loop UI patches. Glucose Guard applies app icons and "
        "MAIN_APP_DISPLAY_NAME only.",
        file=sys.stderr,
    )
    if Path(__file__).with_name("overlays").is_dir():
        print("Overlay Swift files are not injected.", file=sys.stderr)


if __name__ == "__main__":
    main()
