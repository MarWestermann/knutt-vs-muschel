# MDF-Plättchen (3 mm): Relief / V-Carve

## Maß

- Nenn: **25,4 × 25,4 mm** (s. [../spec.md](../spec.md)), auf **500 × 500** genestet (s. [../layout-buche-mdf.md](../layout-buche-mdf.md)).

## Variante A (empfohlen): V-Carve / flache Gravur

- Vektor aus PNG vektorisieren (Inkscape: **Pfad nachverfolgen**, vereinfachen) oder Motive manuell nachzeichnen.
- **Gesamttiefe pro Seite** typisch **0,35–0,75 mm** – Zustellung in mehreren Pässen.
- **Vorschub** moderat, **Drehzahl** nach Datenblatt; **MDF-Staub** absaugen.

## Prototyp-Dateien (eine Seite je Motiv)

| Datei | Zweck |
|-------|--------|
| [knutt_prototype.svg](knutt_prototype.svg) | Test **Knutt**-Seite (vereinfachtes Symbol, zentriert im 25,4-mm-Kachelrahmen). |
| [muschel_prototype.svg](muschel_prototype.svg) | Test **Herzmuschel**-Seite. |

Die Pfade sind bewusst **einfach** – für die Serienfertigung durch echte Silhouetten aus `media/knutt.png` / `media/muschel.png` ersetzen.

**Doppelseitig:** [doppel-seite.md](doppel-seite.md) (Dowel, Reihenfolge, Z-Null).

## Variante B: Heightmap → 3D

- Nur wenn die **Summe** der Zustellungen pro Seite sehr klein bleibt.
- STL in CAM (z. B. FreeCAD 3D-Werkzeugweg) mit flachem Schlichten; **Durchbruch** und Welligkeit prüfen.

## CAM-Reihenfolge (einseitig)

1. Werkstück flach spannen (Vacuum / Doppelklebeband / Randzwingen).
2. **XY-Null** an definierter Kachel-Ecke; **Z-Null** auf Oberfläche.
3. V-Carve-Operation auf Pfad; Simulation.
4. Erst **ein** Plättchen messen, dann Nest.
