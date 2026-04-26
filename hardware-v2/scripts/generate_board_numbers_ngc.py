#!/usr/bin/env python3
"""
LinuxCNC-Vorlage: Zahlen 1-6 oben und links gravieren (separater Job).
Einfacher 7-Segment-Linienfont, damit kein CAM-Textpfad nötig ist.
"""
from __future__ import annotations

import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from generate_board import center_x_header, center_y_header, layout

Z_SAFE = 4.0
Z_ENGRAVE = -0.35
F_XY = 500.0
F_Z = 180.0
S_RPM = 12000

# Segment-Layout im normierten Koordinatensystem [-0.5..0.5] x [-0.5..0.5]
SEGMENTS = {
    "a": ((-0.30, 0.40), (0.30, 0.40)),
    "b": ((0.30, 0.40), (0.30, 0.00)),
    "c": ((0.30, 0.00), (0.30, -0.40)),
    "d": ((-0.30, -0.40), (0.30, -0.40)),
    "e": ((-0.30, 0.00), (-0.30, -0.40)),
    "f": ((-0.30, 0.40), (-0.30, 0.00)),
    "g": ((-0.30, 0.00), (0.30, 0.00)),
}

DIGIT_SEGMENTS = {
    "1": ("b", "c"),
    "2": ("a", "b", "g", "e", "d"),
    "3": ("a", "b", "g", "c", "d"),
    "4": ("f", "g", "b", "c"),
    "5": ("a", "f", "g", "c", "d"),
    "6": ("a", "f", "g", "c", "d", "e"),
}


def digit_strokes(digit: str, cx: float, cy: float, size: float) -> list[tuple[tuple[float, float], tuple[float, float]]]:
    strokes: list[tuple[tuple[float, float], tuple[float, float]]] = []
    for seg in DIGIT_SEGMENTS[digit]:
        (x1, y1), (x2, y2) = SEGMENTS[seg]
        strokes.append(((cx + x1 * size, cy + y1 * size), (cx + x2 * size, cy + y2 * size)))
    return strokes


def engrave_digit(lines: list[str], digit: str, cx: float, cy: float, size: float) -> None:
    for (x1, y1), (x2, y2) in digit_strokes(digit, cx, cy, size):
        lines.append(f"G0 Z{Z_SAFE:.4f}")
        lines.append(f"G0 X{x1:.4f} Y{y1:.4f}")
        lines.append(f"G1 Z{Z_ENGRAVE:.4f} F{F_Z}")
        lines.append(f"G1 X{x2:.4f} Y{y2:.4f} F{F_XY}")
    lines.append(f"G0 Z{Z_SAFE:.4f}")


def main() -> None:
    c, h, gap, out = layout()
    size = min(h, c) * 0.72
    root = Path(__file__).resolve().parent.parent
    dest = root / "gcode" / "numbers_engrave.ngc"
    dest.parent.mkdir(parents=True, exist_ok=True)

    lines: list[str] = [
        "( hardware-v2 Zahlen-Gravur oben+links )",
        "( Z-Null: Oberflaeche Brett oben; XY-Null: unten-links 200x200 )",
        f"( Gravur: Z={Z_ENGRAVE:.2f}, size={size:.2f} )",
        "G21 G17 G90",
        "G54",
        f"M3 S{S_RPM}",
        f"G0 Z{Z_SAFE:.4f}",
        "G0 X0 Y0",
    ]

    # Oben: 1..6
    for ix in range(6):
        cx, cy = center_x_header(ix, c, h, gap)
        engrave_digit(lines, str(ix + 1), cx, cy, size)

    # Links: 1..6 von oben nach unten => im CNC-Y (unten=0) numerisch 6..1
    for iy in range(6):
        cx, cy = center_y_header(iy, c, h, gap)
        engrave_digit(lines, str(6 - iy), cx, cy, size)

    lines.extend([f"G0 Z{Z_SAFE:.4f}", "G0 X0 Y0", "M5", "M2", ""])
    dest.write_text("\n".join(lines), encoding="utf-8")
    print(f"Written {dest}")


if __name__ == "__main__":
    main()

