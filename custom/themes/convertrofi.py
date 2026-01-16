#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Dict, Optional, Tuple


DEFINE_RE = re.compile(
    r"""^\s*@define-color\s+(?P<name>[-\w]+)\s+(?P<value>[^;]+)\s*;\s*$""",
    re.IGNORECASE,
)

RGBA_RE = re.compile(
    r"""^rgba?\(\s*
        (?P<r>\d{1,3})\s*,\s*
        (?P<g>\d{1,3})\s*,\s*
        (?P<b>\d{1,3})\s*
        (?:,\s*(?P<a>[0-9]*\.?[0-9]+)\s*)?
    \)\s*$""",
    re.IGNORECASE | re.VERBOSE,
)

HEX_RE = re.compile(r"^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")


def clamp_u8(n: int) -> int:
    return max(0, min(255, n))


def to_rofi_hex(value: str) -> Optional[str]:
    """
    Convert CSS colors to rofi-friendly #RRGGBBAA where possible.
    Supports:
      - #RRGGBB   -> #RRGGBBFF
      - #RRGGBBAA -> #RRGGBBAA
      - rgba(r,g,b,a) -> #RRGGBBAA
      - rgb(r,g,b) -> #RRGGBBFF
    """
    v = value.strip()

    m = HEX_RE.match(v)
    if m:
        hexpart = m.group(1)
        if len(hexpart) == 6:
            return f"#{hexpart}FF".upper()
        return f"#{hexpart}".upper()

    m = RGBA_RE.match(v)
    if m:
        r = clamp_u8(int(m.group("r")))
        g = clamp_u8(int(m.group("g")))
        b = clamp_u8(int(m.group("b")))
        a_str = m.group("a")
        if a_str is None:
            a = 255
        else:
            a_f = float(a_str)
            # alpha usually 0..1; if user put 0..255, handle that too
            if a_f <= 1.0:
                a = int(round(a_f * 255.0))
            else:
                a = clamp_u8(int(round(a_f)))
        return f"#{r:02X}{g:02X}{b:02X}{a:02X}"

    return None


def parse_walker_css(css_path: Path) -> Dict[str, str]:
    """
    Parse @define-color lines into {name: raw_value}.
    """
    colors: Dict[str, str] = {}
    for line in css_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = DEFINE_RE.match(line)
        if not m:
            continue
        name = m.group("name").strip().lower()
        value = m.group("value").strip()
        colors[name] = value
    return colors


def pick_color(colors: Dict[str, str], keys: Tuple[str, ...]) -> Optional[str]:
    for k in keys:
        if k in colors:
            return colors[k]
    return None


def build_rofi_palette(defined: Dict[str, str]) -> Dict[str, str]:
    """
    Map walker.css define-colors to rofi variables with sensible defaults.
    Expected walker keys (from your screenshot):
      selected-text, text, base, border, foreground, background
    """
    raw_background = pick_color(defined, ("background",))
    raw_background_alt = pick_color(defined, ("base", "background-alt", "background"))
    raw_foreground = pick_color(defined, ("foreground", "text"))
    raw_selected = pick_color(defined, ("selected-text", "border", "selected"))
    raw_active = pick_color(defined, ("active", "border", "selected-text"))
    raw_urgent = pick_color(defined, ("urgent", "selected-text", "border"))

    def conv(v: Optional[str], fallback: str) -> str:
        if not v:
            return fallback
        h = to_rofi_hex(v)
        return h if h else v

    return {
        "background":      conv(raw_background,     "#1E1D2FFF"),
        "background-alt":  conv(raw_background_alt, "#282839FF"),
        "foreground":      conv(raw_foreground,     "#D9E0EEFF"),
        "selected":        conv(raw_selected,       "#7AA2F7FF"),
        "active":          conv(raw_active,         "#ABE9B3FF"),
        "urgent":          conv(raw_urgent,         "#F28FADFF"),
    }


def write_colors_rasi(path: Path, palette: Dict[str, str], theme_name: str) -> None:
    content = (
        f"/* Auto-generated from walker.css for theme: {theme_name} */\n"
        "* {\n"
        f"    background:     {palette['background']};\n"
        f"    background-alt: {palette['background-alt']};\n"
        f"    foreground:     {palette['foreground']};\n"
        f"    selected:       {palette['selected']};\n"
        f"    active:         {palette['active']};\n"
        f"    urgent:         {palette['urgent']};\n"
        "}\n"
    )
    path.write_text(content, encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Generate missing colors.rasi from walker.css for each theme folder."
    )
    ap.add_argument(
        "--themes-dir",
        default=".",
        help="Directory containing theme folders (default: current directory).",
    )
    ap.add_argument(
        "--walker-css",
        default="walker.css",
        help="walker css filename inside each theme folder (default: walker.css)",
    )
    ap.add_argument(
        "--colors-rasi",
        default="colors.rasi",
        help="colors rasi filename to create (default: colors.rasi)",
    )
    ap.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without writing files.",
    )
    args = ap.parse_args()

    themes_dir = Path(args.themes_dir).expanduser().resolve()
    if not themes_dir.is_dir():
        raise SystemExit(f"Themes dir not found: {themes_dir}")

    created = 0
    skipped_existing = 0
    skipped_no_walker = 0
    errors = 0

    for theme_dir in sorted([p for p in themes_dir.iterdir() if p.is_dir()]):
        walker_css = theme_dir / args.walker_css
        colors_rasi = theme_dir / args.colors_rasi

        # Only create colors.rasi if it doesn't exist
        if colors_rasi.exists():
            skipped_existing += 1
            continue

        if not walker_css.exists():
            skipped_no_walker += 1
            continue

        try:
            defined = parse_walker_css(walker_css)
            palette = build_rofi_palette(defined)

            if args.dry_run:
                print(f"[DRY] would create: {colors_rasi}")
            else:
                write_colors_rasi(colors_rasi, palette, theme_dir.name)
                print(f"created: {colors_rasi}")
            created += 1
        except Exception as e:
            errors += 1
            print(f"ERROR: {theme_dir.name}: {e}")

    print(
        f"Done. created={created}, skipped_existing={skipped_existing}, "
        f"skipped_no_walker={skipped_no_walker}, errors={errors}"
    )
    return 0 if errors == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())

