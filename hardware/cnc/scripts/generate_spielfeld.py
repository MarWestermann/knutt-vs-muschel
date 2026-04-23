#!/usr/bin/env python3
"""
Erzeugt mm-genaues 6×6-Spielfeld (Taschen + Außenkontur) als SVG und DXF.
Maße müssen zu hardware/cnc/spec.md passen.
"""
from __future__ import annotations

import math
from pathlib import Path

# --- Parameter (synchron mit spec.md) ---
MARGIN = 4.0
POCKET = 26.0
WEB = 6.0
COLS = ROWS = 6
OUT = 2 * MARGIN + COLS * POCKET + (COLS - 1) * WEB  # 194


def pocket_corners(ix: int, iy: int) -> tuple[float, float, float, float]:
    """Rechteck in XY mit Ursprung unten-links (mathematisch Y nach oben)."""
    x0 = MARGIN + ix * (POCKET + WEB)
    y0 = MARGIN + iy * (POCKET + WEB)
    return x0, y0, x0 + POCKET, y0 + POCKET


def write_svg(path: Path) -> None:
    """SVG: Y nach unten (Bildschirmkonvention), gleiche X wie DXF."""
    lines: list[str] = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{OUT}mm" height="{OUT}mm" viewBox="0 0 {OUT} {OUT}">',
        '  <title>Spielfeld 6x6 Taschen</title>',
        f'  <rect x="0" y="0" width="{OUT}" height="{OUT}" fill="none" stroke="#333" stroke-width="0.2"/>',
    ]
    for iy in range(ROWS):
        for ix in range(COLS):
            x0, y0, x1, y1 = pocket_corners(ix, iy)
            y0s = OUT - y1
            y1s = OUT - y0
            lines.append(
                f'  <rect x="{x0:.3f}" y="{y0s:.3f}" width="{POCKET}" height="{POCKET}" '
                'fill="none" stroke="#0a6" stroke-width="0.15"/>'
            )
    lines.append("</svg>")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_dxf(path: Path) -> None:
    """Minimales ASCII-DXF (R12-kompatibel), POLYLINE für Taschen + Außenrahmen."""
    entities: list[str] = []

    def add_polyline_closed(points: list[tuple[float, float]]) -> None:
        n = len(points)
        entities.append("0\nPOLYLINE\n8\n0\n66\n1\n70\n1")  # closed
        for x, y in points:
            entities.append("0\nVERTEX\n8\n0\n10\n{:.6f}\n20\n{:.6f}".format(x, y))
        entities.append("0\nSEQEND")

    # Außenkontur (CCW)
    add_polyline_closed([(0, 0), (OUT, 0), (OUT, OUT), (0, OUT)])
    # Taschen (CCW)
    for iy in range(ROWS):
        for ix in range(COLS):
            x0, y0, x1, y1 = pocket_corners(ix, iy)
            add_polyline_closed([(x0, y0), (x1, y0), (x1, y1), (x0, y1)])

    header = [
        "0\nSECTION\n2\nHEADER\n9\n$ACADVER\n1\nAC1009\n0\nENDSEC",
        "0\nSECTION\n2\nTABLES\n0\nENDSEC",
        "0\nSECTION\n2\nBLOCKS\n0\nENDSEC",
        "0\nSECTION\n2\nENTITIES",
    ]
    footer = ["0\nENDSEC", "0\nEOF"]
    path.write_text("\n".join(header + entities + footer) + "\n", encoding="utf-8")


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    assert math.isclose(OUT, 194.0), OUT
    write_svg(root / "spielfeld.svg")
    write_dxf(root / "spielfeld.dxf")
    print(f"Written {OUT} mm field -> spielfeld.svg, spielfeld.dxf")


if __name__ == "__main__":
    main()
