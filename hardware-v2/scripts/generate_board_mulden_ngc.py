#!/usr/bin/env python3
"""
LinuxCNC-Vorlage: schüsselförmige Mulden (6x6) mit quadratischer Top-Ansicht
und gerundeten Ecken.
Außen nahezu flach, zur Mitte tiefer ("flacher See"-Profil).
Werkzeug 6 mm (TOOL_R=3), Mittelpunkte aus board-Layout.
"""
from __future__ import annotations

import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from generate_board import MULDE_CORNER_R, MULDE_SIDE, centers_play, layout

TOOL_R = 3.0
Z_SAFE = 5.0
Z_BOTTOM = -3.5
F_XY = 750.0
F_Z = 200.0
F_PLUNGE = 150.0
# Abstand der Kontur-Insets (außen nach innen)
STEPOVER = 2.2
# Formparameter: 1.0 = linear, >1.0 = flacher Rand + steilere Mitte
PROFILE_EXPONENT = 1.8
ARC_STEPS = 6


def inset_sequence(half_max: float) -> list[float]:
    """Inset-Abstände von außen nach innen."""
    out: list[float] = []
    inset = 0.0
    while inset < half_max - 0.9:
        out.append(inset)
        inset += STEPOVER
    return out


def depth_for_inset(inset: float, inset_max: float) -> float:
    """Ziel-Z für Kontur-Inset: außen ~0, innen Z_BOTTOM."""
    if inset_max <= 0.0:
        return Z_BOTTOM
    t = inset / inset_max  # 0 am Rand, 1 nahe Mitte
    t = max(0.0, min(1.0, t))
    shaped = t**PROFILE_EXPONENT
    return Z_BOTTOM * shaped


def rounded_rect_path(
    xc: float, yc: float, width: float, height: float, radius: float, arc_steps: int
) -> list[tuple[float, float]]:
    """Konturpunkte (CCW) für Rechteck mit gerundeten Ecken."""
    import math

    hw = width / 2.0
    hh = height / 2.0
    r = max(0.0, min(radius, hw, hh))
    if r <= 1e-6:
        return [
            (xc + hw, yc - hh),
            (xc + hw, yc + hh),
            (xc - hw, yc + hh),
            (xc - hw, yc - hh),
            (xc + hw, yc - hh),
        ]

    pts: list[tuple[float, float]] = []
    corners = [
        (xc + hw - r, yc + hh - r, 0.0, math.pi / 2.0),
        (xc - hw + r, yc + hh - r, math.pi / 2.0, math.pi),
        (xc - hw + r, yc - hh + r, math.pi, 3.0 * math.pi / 2.0),
        (xc + hw - r, yc - hh + r, 3.0 * math.pi / 2.0, 2.0 * math.pi),
    ]
    for ccx, ccy, a0, a1 in corners:
        for i in range(arc_steps + 1):
            a = a0 + (a1 - a0) * (i / arc_steps)
            pts.append((ccx + r * math.cos(a), ccy + r * math.sin(a)))
    pts.append(pts[0])
    return pts


def pocket_at(xc: float, yc: float, lines: list[str]) -> None:
    half_max = MULDE_SIDE / 2.0 - TOOL_R
    if half_max <= 1.0:
        return
    corner_max = max(0.0, MULDE_CORNER_R - TOOL_R)
    insets = inset_sequence(half_max)
    if not insets:
        return
    inset_max = insets[-1] if insets[-1] > 1e-9 else half_max

    for inset in insets:
        nz = depth_for_inset(inset, inset_max)
        side = 2.0 * (half_max - inset)
        if side <= 1.5:
            continue
        corner = max(0.0, corner_max - inset)
        pts = rounded_rect_path(xc, yc, side, side, corner, ARC_STEPS)
        x0, y0 = pts[0]
        lines.append(f"G0 Z{Z_SAFE:.4f}")
        lines.append(f"G0 X{x0:.4f} Y{y0:.4f}")
        lines.append(f"G1 X{x0:.4f} Y{y0:.4f} Z{nz:.4f} F{F_PLUNGE}")
        for px, py in pts[1:]:
            lines.append(f"G1 X{px:.4f} Y{py:.4f} F{F_XY}")

    # kleiner Endkreis im Zentrum für glatten Muldenboden
    center_r = 0.8
    lines.append(f"G0 Z{Z_SAFE:.4f}")
    lines.append(f"G0 X{(xc + center_r):.4f} Y{yc:.4f}")
    lines.append(f"G1 X{(xc + center_r):.4f} Y{yc:.4f} Z{Z_BOTTOM:.4f} F{F_PLUNGE}")
    lines.append(f"G3 X{(xc + center_r):.4f} Y{yc:.4f} I{-center_r:.4f} J0.0000 F{F_XY}")


def main() -> None:
    c, h, gap, out = layout()
    root = Path(__file__).resolve().parent.parent
    dest = root / "gcode" / "mulden_pockets.ngc"
    dest.parent.mkdir(parents=True, exist_ok=True)

    lines: list[str] = [
        "( hardware-v2 Mulden 6x6 – LinuxCNC See-Muldenprofil )",
        "( Z-Null: Oberflaeche Brett oben; XY-Null: unten-links 200x200 )",
        "( Werkzeug 6 mm angenommen – T/M und tool.tbl anpassen )",
        (
            f"( Profil: square-rounded, side={MULDE_SIDE:.2f}, corner_r={MULDE_CORNER_R:.2f}, "
            f"Z_BOTTOM={Z_BOTTOM:.2f}, exponent={PROFILE_EXPONENT:.2f}, stepover={STEPOVER:.2f} )"
        ),
        "G21 G17 G90",
        "G54",
        "M3 S9000",
        f"G0 Z{Z_SAFE:.4f}",
        "G0 X0 Y0",
    ]
    for iy in range(6):
        row = range(6) if iy % 2 == 0 else range(5, -1, -1)
        for ix in row:
            xc, yc = centers_play(ix, iy, c, h, gap)
            lines.append(f"( Mulde ix={ix} iy={iy} center {xc:.3f} {yc:.3f} )")
            pocket_at(xc, yc, lines)

    lines.extend([f"G0 Z{Z_SAFE:.4f}", "G0 X0 Y0", "M5", "M2", ""])
    dest.write_text("\n".join(lines), encoding="utf-8")
    print(f"Written {dest}")


if __name__ == "__main__":
    main()
