# CAM: Spielfeld-Pocket (Buche) und LinuxCNC

## Quelle

- 2D: [spielfeld.dxf](spielfeld.dxf) / [spielfeld.svg](spielfeld.svg) (regenerieren: `python3 scripts/generate_spielfeld.py`)
- Maße: [spec.md](spec.md)

## Pocket-Parameter

| Parameter | Wert |
|-----------|------|
| Taschenmaß | 26 × 26 mm |
| Tiefe | **9,5 mm** (Restboden ≈ 8,5 mm bei 18 mm Material) |
| Werkzeug | **6 mm** HM (Torus empfohlen) |
| CAM | Spiral oder Schichten; **G42/G41** oder CAM-Innenoffset 3 mm |

## Generiertes G-Code-Beispiel

- Datei: [gcode/spielfeld_pockets.ngc](gcode/spielfeld_pockets.ngc)  
- Erzeugen: `python3 scripts/generate_field_pocket_ngc.py`

Das Skript fräst **36 Rechteck-Umrisse** in Z-Schichten (nicht optimiert wie professionelles CAM – dafür reproduzierbar und ohne externe Software).

## Simulation / Dry-Run

1. **LinuxCNC** oder **CAMotics**: Datei laden, Geschwindigkeit / Override niedrig.
2. **G54** auf **obere Kante** Brett, **Ursprung unten-links** am **194×194-Außenrechteck** des Spielfeldes (wie in der NG-Kommentierung).
3. **Spindel aus** oder **Luft-Schnitte**: Z-Offset in der Maschine oder `G10` anpassen.
4. **Kollision**: Sicherheits-Z (`Z5` im Beispiel) gegen Einrichtung prüfen.

## Alternative: CAM aus DXF

DXF in **FreeCAD Path**, **Fusion**, **Sheetcam** o. Ä. importieren, Pocket auf geschlossene Rechtecke (nur die **inneren** 36 Polygone, nicht die Außenkontur) mit Werkzeug 6 mm und Spiralbahn – oft schneller und werkzeugfreundlicher als das Beispiel-G-Code.
