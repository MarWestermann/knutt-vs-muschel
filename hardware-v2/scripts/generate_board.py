#!/usr/bin/env python3
"""
200×200 mm Spielfeld: 7×7-Layout wie Web (Koordinaten + 6×6 Mulden).
Schreibt board.svg (Y nach unten) und board.dxf (Y nach oben, CNC-üblich).
"""
from __future__ import annotations

from pathlib import Path

# --- Parameter (synchron mit spec.md) ---
OUT = 200.0
GAP = 1.2
HEADER_RATIO = 0.55  # h = HEADER_RATIO * c
# h + 6*c + 6*GAP = OUT  und  h = HEADER_RATIO * c  ->  c = (OUT - 6*GAP) / (6 + HEADER_RATIO)
_c = (OUT - 6.0 * GAP) / (6.0 + HEADER_RATIO)
_h = HEADER_RATIO * _c
MULDE_D = 29.0
MULDE_R = MULDE_D / 2.0


def layout() -> tuple[float, float, float, float]:
    """Gibt (c, h, gap, out) zurück."""
    return _c, _h, GAP, OUT


def play_cell_left(ix: int, c: float, h: float, gap: float) -> float:
    """Linke Kante Spielfeld-Spalte ix=0..5 (x=1..6)."""
    return h + gap + ix * (c + gap)


def play_row_bottom(iy: int, c: float, gap: float) -> float:
    """Untere Kante Spielfeld-Zeile iy=0..5 von unten; iy=0 = Spiel-y=6."""
    return iy * (c + gap)


def centers_play(ix: int, iy: int, c: float, h: float, gap: float) -> tuple[float, float]:
    """Mittelpunkt Mulde; ix,iy von unten-links im Spielfeld."""
    x = play_cell_left(ix, c, h, gap) + c / 2.0
    y = play_row_bottom(iy, c, gap) + c / 2.0
    return x, y


def center_x_header(ix: int, c: float, h: float, gap: float) -> tuple[float, float]:
    """Mitte Koordinate oben für Spalte ix+1 (CNC Y oben)."""
    x = play_cell_left(ix, c, h, gap) + c / 2.0
    y = OUT - h / 2.0
    return x, y


def center_y_header(iy: int, c: float, h: float, gap: float) -> tuple[float, float]:
    """Mitte Koordinate links für Zeile Spiel-y = 6-iy (iy=0 -> y=6 unten)."""
    x = h / 2.0
    y = play_row_bottom(iy, c, gap) + c / 2.0
    return x, y


def write_svg(path: Path, c: float, h: float, gap: float, out: float) -> None:
    """SVG: Y nach unten."""
    lines: list[str] = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{out}mm" height="{out}mm" '
        f'viewBox="0 0 {out} {out}">',
        '  <title>Spielfeld 200mm Glaskiesel</title>',
        f'  <rect x="0" y="0" width="{out}" height="{out}" fill="#f4e4c1" stroke="#333" stroke-width="0.25"/>',
        f'  <rect x="0" y="0" width="{h}" height="{h}" fill="none" stroke="#999" stroke-dasharray="1 1" stroke-width="0.15"/>',
        '  <g id="mulden" fill="none" stroke="#1a8c8a" stroke-width="0.2">',
    ]
    for iy in range(6):
        for ix in range(6):
            xc, y_up = centers_play(ix, iy, c, h, gap)
            y_svg = out - y_up
            lines.append(f'    <circle cx="{xc:.4f}" cy="{y_svg:.4f}" r="{MULDE_R:.4f}"/>')
    lines.append("  </g>")
    lines.append('  <g id="koordinaten" font-family="system-ui,Segoe UI,sans-serif" font-weight="800" '
                 f'font-size="{min(h, c) * 0.52:.2f}" text-anchor="middle" dominant-baseline="middle" fill="#1a1a1a">')
    for ix in range(6):
        xc, y_up = center_x_header(ix, c, h, gap)
        y_svg = out - y_up
        lines.append(f'    <text x="{xc:.4f}" y="{y_svg:.4f}">{ix + 1}</text>')
    for iy in range(6):
        xc, y_up = center_y_header(iy, c, h, gap)
        y_svg = out - y_up
        label = 6 - iy
        lines.append(f'    <text x="{xc:.4f}" y="{y_svg:.4f}">{label}</text>')
    lines.extend(["  </g>", "</svg>"])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_dxf(path: Path, c: float, h: float, gap: float, out: float) -> None:
    """DXF: Y nach oben; Kreise + TEXT + Außenrahmen."""
    entities: list[str] = []

    def add_polyline_closed(points: list[tuple[float, float]]) -> None:
        entities.append("0\nPOLYLINE\n8\n0\n66\n1\n70\n1")
        for x, y in points:
            entities.append("0\nVERTEX\n8\n0\n10\n{:.6f}\n20\n{:.6f}".format(x, y))
        entities.append("0\nSEQEND")

    def add_circle(cx: float, cy: float, r: float) -> None:
        entities.extend(
            [
                "0\nCIRCLE\n8\n0",
                f"10\n{cx:.6f}\n20\n{cy:.6f}\n40\n{r:.6f}",
            ]
        )

    def add_text(x: float, y: float, hgt: float, txt: str) -> None:
        # TEXT: Minimal R12
        entities.extend(
            [
                "0\nTEXT\n8\n0",
                f"10\n{x:.6f}\n20\n{y:.6f}\n40\n{hgt:.6f}\n1\n{txt}",
            ]
        )

    add_polyline_closed([(0, 0), (out, 0), (out, out), (0, out)])
    add_polyline_closed([(0, out - h), (h, out - h), (h, out), (0, out)])

    for iy in range(6):
        for ix in range(6):
            xc, y_up = centers_play(ix, iy, c, h, gap)
            add_circle(xc, y_up, MULDE_R)

    th = min(h, c) * 0.48
    for ix in range(6):
        xc, y_up = center_x_header(ix, c, h, gap)
        add_text(xc, y_up, th, str(ix + 1))
    for iy in range(6):
        xc, y_up = center_y_header(iy, c, h, gap)
        add_text(xc, y_up, th, str(6 - iy))

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
    c, h, gap, out = layout()
    assert abs(h + 6 * c + 6 * gap - out) < 1e-6, (h, c, gap, out)
    assert MULDE_D <= c - 0.25, "Mulde passt nicht in Zelle – GAP oder HEADER_RATIO anpassen"
    write_svg(root / "board.svg", c, h, gap, out)
    write_dxf(root / "board.dxf", c, h, gap, out)
    print(f"c={c:.3f} mm, h={h:.3f} mm, gap={gap} mm, mulde_d={MULDE_D} mm -> board.svg, board.dxf")


if __name__ == "__main__":
    main()
