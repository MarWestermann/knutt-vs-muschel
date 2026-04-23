# Koffer (Buche): Teile, Innenmaße, Scharnier, Zuschnitt

Siehe [../spec.md](../spec.md) (Material, Plättchenstapel) und [../layout-buche-mdf.md](../layout-buche-mdf.md).

## Prinzip

- **Unterteil** (Boden mit 6×6-Taschen + Wände) und **Deckel** sind **getrennte** Zuschnitte, Verbindung **Scharnier** (Piano-Scharnier empfohlen).
- **Innenhöhe** für den Plättchenstapel **> 18 mm** → **Seiten** aus **mehreren** Streifen desselben **800 mm**-Rohlings oder Lamellen-Stack.

## Bezugsmaße Spielfeld

- Raster **194 × 194 mm** (nur Taschen, s. `spielfeld.*`).
- Vorschlag **Bodenplatte** (oben Aufsicht): Außen **210 × 210 mm** → **8 mm** Rand rings um das 194-mm-Raster (zentriert).

## Plättchenfach (Innenmaß)

| Größe | Richtwert |
|-------|-----------|
| Grundriss innen | ≥ **26,5 × 26,5 mm** je „Slot“ nicht nötig – **ein gemeinsames Fach** neben dem Spielfeld |
| Bodenfläche Fach | z. B. **30 × 110 mm** (frei wählbar, solange Stapel passt) |
| **Innenhöhe** | **120–125 mm** für **36 × 3 mm** + Luft (s. spec) |

Das Fach liegt **nebendem** erhabenen Spielfeld oder **darunter** (tieferer Korpus) – im CAD festlegen.

## Deckel (ausgehöhlt)

- Außen wie Kofferaußenmaß (z. B. **210 × 210 mm** Deckel, wenn Korpus innen quadratisch geplant).
- **Innenaussparung** muss das **Spielfeld + Rand** freilassen: Aussparung z. B. **≥ 196 × 196 mm** bei **7 mm** verbleibendem Rahmen (Werte an echte Außenmaße anpassen).
- **Rückkante**: massiver Streifen für **Piano-Scharnier** (ca. **25–40 mm** breit lassen, je nach Scharnierbreite).
- **Scharnier-Sitz**: Maße vom **gekauften** Band; Nut/Anlage in **Deckel** und **Unterteil** im gleichen CAD-Setup zeichnen.

## Scharnier & Verschluss

| Element | Hinweis |
|---------|---------|
| Scharnier | **Piano** volle Rückkante oder **2–3 Scharniere** |
| Verschluss | optional **Magnete** (bohren/einlassen) oder **Schnapper** |
| Griff | optional **Mulde** im Deckel-Rahmen fräsen |

## Zuschnitt aus Buche 18 × 200 × 800 mm (Richtwerte)

Längen **addieren** mit Säge-/Fräskerf (~3–5 mm pro Schnitt) – im CAD nachziehen.

| Teil | Richtmaß (mm) | Menge | Notiz |
|------|----------------|-------|-------|
| Boden | **210 × 210** (× 18 dick) | 1 | Taschen fräsen |
| Deckel-Rohling | **210 × 210** | 1 | Innen aushöhlen |
| Seiten / Streifen | z. B. **120 × 200** (Höhe × Länge) | 4× um Eck | Oder Lamellen **18 × 18** gestapelt mit Leim (aufwändiger) |
| Zwischenstege Fach | aus Rest | — | Reststücke aus 800 mm-Streifen |

**Beispiel** Längenbudget auf **800 mm** „Streifenbreite 200“: zwei **210**-Quadrate (Boden + Deckel) parallel verschachtelt geht nicht in 200 Breite – stattdessen **Boden und Deckel nacheinander** aus **200×400+** schneiden oder Boden **210** aus **200×210** und Deckel aus zweitem Stück. Praktisch: **Säge** grob auf **Zuschnitte**, dann **CNC** für Taschen und Deckelinnenseite.

### Inkscape / FreeCAD

1. **Inkscape**: Außenrechtecke + 194-mm-Raster als Referenz importieren (`../spielfeld.svg`); Maßstab 1:1 mm.
2. **FreeCAD**: Part Design für Korpus, Sketch für Scharnier-Nut; Path-Werkzeug für CAM-Export optional.

## Deckel-CAM (Kurz)

- Große **Tasche** / mehrstufige **Pocket** für Innere, **Rand** stehen lassen.
- Datei-Vorlage kann aus demselben DXF-Workflow wie das Spielfeld kommen (Rechteck-Innenkontur); hier keine feste `.ngc`, weil vom gewählten Kofferaußenmaß abhängig.
