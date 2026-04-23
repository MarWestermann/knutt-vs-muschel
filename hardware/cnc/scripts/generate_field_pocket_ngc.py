#!/usr/bin/env python3
"""
LinuxCNC G-Code: 36 rechteckige Pockets (Spielfeld) aus spec.md.
Werkzeug: 6 mm Torus/Schaft, Tasche 26 mm, Steg 6 mm, Rand 4 mm, Z bis -9.5 mm.

VOR ERSTEM LAUF: Maschinennull, G54, Vorschübe, Spindel-S, Sicherheits-Z prüfen.
"""
from __future__ import annotations

import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from generate_spielfeld import COLS, MARGIN, OUT, POCKET, ROWS, WEB

TOOL_R = 3.0  # 6 mm Durchmesser
Z_SAFE = 5.0
Z_BOTTOM = -9.5
Z_STEP = 2.0
# Vorschübe (konservativ; an Maschine/Holz anpassen)
F_XY = 900.0
F_Z = 250.0
F_PLUNGE = 200.0


def pocket_inner_rect(ix: int, iy: int) -> tuple[float, float, float, float]:
    """Fräsermittelpunkte: 3 mm von Taschenwand."""
    x0 = MARGIN + ix * (POCKET + WEB) + TOOL_R
    y0 = MARGIN + iy * (POCKET + WEB) + TOOL_R
    x1 = MARGIN + ix * (POCKET + WEB) + POCKET - TOOL_R
    y1 = MARGIN + iy * (POCKET + WEB) + POCKET - TOOL_R
    return x0, y0, x1, y1


def rect_pass(x0: float, y0: float, x1: float, y1: float, z: float, lines: list[str]) -> None:
    lines.append(f"( pocket pass Z{z:.2f} )")
    lines.append(f"G1 X{x0:.4f} Y{y0:.4f} Z{z:.4f} F{F_PLUNGE}")
    lines.append(f"G1 X{x1:.4f} Y{y0:.4f} F{F_XY}")
    lines.append(f"G1 X{x1:.4f} Y{y1:.4f} F{F_XY}")
    lines.append(f"G1 X{x0:.4f} Y{y1:.4f} F{F_XY}")
    lines.append(f"G1 X{x0:.4f} Y{y0:.4f} F{F_XY}")


def pocket_all_z(ix: int, iy: int, lines: list[str]) -> None:
    x0, y0, x1, y1 = pocket_inner_rect(ix, iy)
    z = 0.0
    targets: list[float] = []
    while True:
        nz = z - Z_STEP
        if nz <= Z_BOTTOM:
            if z > Z_BOTTOM + 1e-9:
                targets.append(Z_BOTTOM)
            break
        z = nz
        targets.append(z)
    for zt in targets:
        lines.append(f"G0 Z{Z_SAFE:.4f}")
        lines.append(f"G0 X{x0:.4f} Y{y0:.4f}")
        rect_pass(x0, y0, x1, y1, zt, lines)


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    out = root / "gcode" / "spielfeld_pockets.ngc"
    out.parent.mkdir(parents=True, exist_ok=True)

    lines: list[str] = [
        "( Spielfeld 6x6 Pockets Buche - LinuxCNC Vorlage )",
        "( NULL: obere Fläche Brett, Ursprung unten-links 194x194-Aussen )",
        "( Tiefenlage prüfen: Restboden ca. 8.5 mm bei 18 mm Material )",
        "G21 G17 G90",
        "G54",
        "M3 S10000 ( Drehzahl an Werkzeug/Holz anpassen )",
        f"G0 Z{Z_SAFE:.4f}",
        "G0 X0 Y0",
        "( --- Simulation/Dry-Run: M3 aus und Z offset nutzen, oder Geschwindigkeit reduzieren --- )",
    ]

    for iy in range(ROWS):
        row = range(COLS) if iy % 2 == 0 else range(COLS - 1, -1, -1)
        for ix in row:
            lines.append(f"( Feld ix={ix} iy={iy} )")
            pocket_all_z(ix, iy, lines)

    lines.extend(
        [
            f"G0 Z{Z_SAFE:.4f}",
            "G0 X0 Y0",
            "M5",
            "M2",
            "",
        ]
    )
    out.write_text("\n".join(lines), encoding="utf-8")
    print(f"Written {out} ({OUT} mm board, pockets to {Z_BOTTOM} mm)")


if __name__ == "__main__":
    main()
