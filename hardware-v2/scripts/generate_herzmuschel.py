#!/usr/bin/env python3
"""
Erzeugt eine Herzmuschel-Silhouette als SVG (Cardium edule, stilisiert).

Ziel: Vorlage fuer einen Stempel, importierbar in FreeCAD
(Sketcher -> "Sketch aus SVG erstellen" oder Draft -> SVG importieren),
anschliessend Pad/Pocket auf den Stempelkoerper.

Geometrie:
- Aussenkontur: glatte geschlossene Catmull-Rom-Kurve (in Cubic Bezier
  konvertiert), die durch handabgestimmte Anker laeuft.
- 17 radiale Rippen als Linien vom Umbo (oben) zur Innenseite der Kontur.
- Umbo (Buckel) als kleiner Bogen oben.

Einheiten: mm, Y nach unten (SVG-Konvention).
Die Strokes/Fills sind nur fuer die Vorschau gedacht. FreeCAD importiert
die *Geometrie* der Pfade unabhaengig von Farben.

Schreibt:
  herzmuschel.svg            Komplette Grafik (Kontur + Rippen + Umbo)
  herzmuschel-outline.svg    Nur Aussenkontur (einfacher Silhouetten-Stempel)
"""
from __future__ import annotations

import math
from pathlib import Path

# -------- Parameter --------
WIDTH = 50.0          # Gesamtbreite der Muschel (mm)
HEIGHT = 46.0         # Gesamthoehe der Muschel (mm)
MARGIN = 4.0          # Rand im SVG-ViewBox (mm)

UMBO_OFFSET_Y = 1.5   # Abstand Umbo-Spitze vom oberen Rand der Muschel-Bbox

N_RIBS = 17           # Anzahl Rippen
RIB_FAN_DEG = 134.0   # Faecheroeffnung der Rippen (Grad, symmetrisch)
RIB_START_R = 5.0     # Innen-Radius der Rippen ab Umbo (mm)
RIB_INSET = 2.2       # Abstand der Rippen-Spitzen zur Aussenkontur (mm)

UMBO_R = 2.4          # Radius des Umbo-Buckels (mm)


def _fmt(v: float) -> str:
    return f"{v:.3f}"


# -------- Catmull-Rom -> Cubic Bezier --------
def _catmull_rom_closed(points: list[tuple[float, float]]) -> str:
    """Geschlossene Catmull-Rom-Kurve (uniform) -> SVG-Pfad mit cubic Beziers."""
    n = len(points)
    out = [f"M {_fmt(points[0][0])} {_fmt(points[0][1])}"]
    for i in range(n):
        p0 = points[(i - 1) % n]
        p1 = points[i]
        p2 = points[(i + 1) % n]
        p3 = points[(i + 2) % n]
        c1x = p1[0] + (p2[0] - p0[0]) / 6.0
        c1y = p1[1] + (p2[1] - p0[1]) / 6.0
        c2x = p2[0] - (p3[0] - p1[0]) / 6.0
        c2y = p2[1] - (p3[1] - p1[1]) / 6.0
        out.append(
            f"C {_fmt(c1x)} {_fmt(c1y)}, {_fmt(c2x)} {_fmt(c2y)}, {_fmt(p2[0])} {_fmt(p2[1])}"
        )
    out.append("Z")
    return " ".join(out)


def _outline_anchors(cx: float, cy_umbo: float) -> list[tuple[float, float]]:
    """Anker fuer die Aussenkontur (Reihenfolge im Uhrzeigersinn ab Umbo)."""
    w = WIDTH
    h = HEIGHT
    # Relativ zum Umbo: y nach unten ist positiv.
    rel = [
        (0.00, 0.00),                         # Umbo
        (0.12 * w, 0.02 * h),                 # rechte Schulter (eng am Umbo)
        (0.32 * w, 0.10 * h),                 # rechte obere Flanke
        (0.46 * w, 0.24 * h),                 # rechter oberer Bogen
        (0.50 * w, 0.46 * h),                 # rechte Mitte (groesste Breite)
        (0.45 * w, 0.70 * h),                 # rechte untere Flanke
        (0.30 * w, 0.92 * h),                 # rechte Boden-Rundung
        (0.00, 1.00 * h),                     # Boden-Mitte
        (-0.30 * w, 0.92 * h),                # linke Boden-Rundung
        (-0.45 * w, 0.70 * h),                # linke untere Flanke
        (-0.50 * w, 0.46 * h),                # linke Mitte
        (-0.46 * w, 0.24 * h),                # linker oberer Bogen
        (-0.32 * w, 0.10 * h),                # linke obere Flanke
        (-0.12 * w, 0.02 * h),                # linke Schulter
    ]
    return [(cx + dx, cy_umbo + dy) for (dx, dy) in rel]


def _outline_path(cx: float, cy_umbo: float) -> str:
    return _catmull_rom_closed(_outline_anchors(cx, cy_umbo))


def _outline_radius(theta_rad: float) -> float:
    """Approximierter Radius der Aussenkontur fuer Strahl mit Winkel theta
    (theta = 0 = senkrecht nach unten, positiv im Uhrzeigersinn).

    Naeherung: Halbellipse (a = WIDTH/2, b = HEIGHT). Mit RIB_INSET als
    Sicherheitsabstand bleiben die Rippen-Enden zuverlaessig innerhalb der
    Catmull-Rom-Aussenkontur.
    """
    a = WIDTH / 2.0
    b = HEIGHT
    s = math.sin(theta_rad)
    c = math.cos(theta_rad)
    return 1.0 / math.sqrt((s / a) ** 2 + (c / b) ** 2)


def _rib_line(cx: float, cy_umbo: float, theta_rad: float) -> str:
    """Rippe als einfache Linie (M..L). Fuer einen Linien-Stempel (V-Bit Gravur
    bzw. erhabene Stege) ist das die natuerlichste Darstellung."""
    s = math.sin(theta_rad)
    c = math.cos(theta_rad)
    r_in = RIB_START_R
    r_out = max(_outline_radius(theta_rad) - RIB_INSET, r_in + 1.0)
    p_in = (cx + r_in * s, cy_umbo + r_in * c)
    p_out = (cx + r_out * s, cy_umbo + r_out * c)
    return f"M {_fmt(p_in[0])} {_fmt(p_in[1])} L {_fmt(p_out[0])} {_fmt(p_out[1])}"


def _umbo_path(cx: float, cy_umbo: float) -> str:
    """Kleiner Bogen am Umbo (Buckel) als geschlossene Form."""
    r = UMBO_R
    left = (cx - r, cy_umbo + 0.7 * r)
    right = (cx + r, cy_umbo + 0.7 * r)
    return (
        f"M {_fmt(left[0])} {_fmt(left[1])} "
        f"Q {_fmt(cx)} {_fmt(cy_umbo - 0.6 * r)} {_fmt(right[0])} {_fmt(right[1])} "
        f"Q {_fmt(cx)} {_fmt(left[1] + 0.55 * r)} {_fmt(left[0])} {_fmt(left[1])} "
        f"Z"
    )


def _svg_full(outline: str, ribs: list[str], umbo: str, view_w: float, view_h: float) -> str:
    rib_paths = "\n      ".join(f'<path d="{d}"/>' for d in ribs)
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{_fmt(view_w)}mm" height="{_fmt(view_h)}mm" viewBox="0 0 {_fmt(view_w)} {_fmt(view_h)}">
  <title>Herzmuschel (Stempelvorlage)</title>
  <desc>Cardium edule, stilisiert. Aussenkontur + 17 radiale Rippen + Umbo.
        Einheiten: mm. Fuer FreeCAD: Sketcher -> "Sketch aus SVG" -> Pad.</desc>
  <g id="muschel-kontur" fill="#e7c79a" stroke="#3a2a14" stroke-width="0.4" stroke-linejoin="round">
    <path d="{outline}"/>
  </g>
  <g id="muschel-rippen" fill="none" stroke="#3a2a14" stroke-width="0.55" stroke-linecap="round">
      {rib_paths}
  </g>
  <g id="muschel-umbo" fill="#b8915c" stroke="#3a2a14" stroke-width="0.35" stroke-linejoin="round">
    <path d="{umbo}"/>
  </g>
</svg>
'''


def _svg_outline_only(outline: str, view_w: float, view_h: float) -> str:
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{_fmt(view_w)}mm" height="{_fmt(view_h)}mm" viewBox="0 0 {_fmt(view_w)} {_fmt(view_h)}">
  <title>Herzmuschel - Aussenkontur</title>
  <g id="muschel-kontur" fill="#e7c79a" stroke="#3a2a14" stroke-width="0.4" stroke-linejoin="round">
    <path d="{outline}"/>
  </g>
</svg>
'''


def main() -> None:
    view_w = WIDTH + 2 * MARGIN
    view_h = HEIGHT + 2 * MARGIN
    cx = view_w / 2.0
    cy_umbo = MARGIN + UMBO_OFFSET_Y

    outline = _outline_path(cx, cy_umbo)
    umbo = _umbo_path(cx, cy_umbo + 0.3)

    half = math.radians(RIB_FAN_DEG / 2.0)
    if N_RIBS == 1:
        angles = [0.0]
    else:
        step = (2 * half) / (N_RIBS - 1)
        angles = [-half + i * step for i in range(N_RIBS)]
    ribs = [_rib_line(cx, cy_umbo, a) for a in angles]

    out_dir = Path(__file__).resolve().parent.parent
    (out_dir / "herzmuschel.svg").write_text(
        _svg_full(outline, ribs, umbo, view_w, view_h), encoding="utf-8"
    )
    (out_dir / "herzmuschel-outline.svg").write_text(
        _svg_outline_only(outline, view_w, view_h), encoding="utf-8"
    )

    print(f"geschrieben: {out_dir / 'herzmuschel.svg'}")
    print(f"geschrieben: {out_dir / 'herzmuschel-outline.svg'}")
    print(f"Bbox Muschel: {WIDTH:.1f} x {HEIGHT:.1f} mm, ViewBox: {view_w:.1f} x {view_h:.1f} mm")


if __name__ == "__main__":
    main()
