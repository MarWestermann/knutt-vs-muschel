#!/usr/bin/env python3
"""
LinuxCNC-Vorlage: konzentrische Kreise je Mulde (6x6), Z-Schichten.
Werkzeug 6 mm (TOOL_R=3), Mittelpfade aus board-Layout.
Nur Startpunkt für Simulation – professionelle Spiral-Pockets besser in CAM.
"""
from __future__ import annotations

import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from generate_board import MULDE_R, centers_play, layout

TOOL_R = 3.0
Z_SAFE = 5.0
Z_BOTTOM = -3.5
Z_STEP = 1.5
F_XY = 750.0
F_Z = 200.0
F_PLUNGE = 150.0
# Radiale Abstände der Kreisbahnen (Außen nach innen)
STEPOVER = 2.2


def radii_sequence() -> list[float]:
    r_max = MULDE_R - TOOL_R
    out: list[float] = []
    r = r_max
    while r > 1.2:
        out.append(r)
        r -= STEPOVER
    return out


def z_levels() -> list[float]:
    levels: list[float] = []
    z = 0.0
    while True:
        nz = z - Z_STEP
        if nz <= Z_BOTTOM + 1e-9:
            levels.append(Z_BOTTOM)
            break
        levels.append(nz)
        z = nz
    return levels


def pocket_at(xc: float, yc: float, lines: list[str]) -> None:
    radii = radii_sequence()
    for nz in z_levels():
        for rp in radii:
            x0 = xc + rp
            lines.append(f"G0 Z{Z_SAFE:.4f}")
            lines.append(f"G0 X{x0:.4f} Y{yc:.4f}")
            lines.append(f"G1 X{x0:.4f} Y{yc:.4f} Z{nz:.4f} F{F_PLUNGE}")
            lines.append(f"G3 X{x0:.4f} Y{yc:.4f} I{-rp:.4f} J0.0000 F{F_XY}")


def main() -> None:
    c, h, gap, out = layout()
    root = Path(__file__).resolve().parent.parent
    dest = root / "gcode" / "mulden_pockets.ngc"
    dest.parent.mkdir(parents=True, exist_ok=True)

    lines: list[str] = [
        "( hardware-v2 Mulden 6x6 – LinuxCNC Vorlage )",
        "( Z-Null: Oberflaeche Brett oben; XY-Null: unten-links 200x200 )",
        "( Werkzeug 6 mm angenommen – T/M und tool.tbl anpassen )",
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
