# Herstellung: 200×200 Spielfeld (hardware-v2)

## 1. Material

- Rohling **Buche 18 × 200 × 800 mm** – daraus **200×200 mm** Bretter sägen (pro Stück **≤ 200 mm** Länge wegen Sägekerf planen; aus **800 mm** typisch **vier** Teile minus Kerf).
- Ober- und Unterseite **plan** (Handhobel / Abrichthobel / Fräse), damit **Z-Null** stimmt.

## 2. Vektoren erzeugen

```bash
cd hardware-v2
python3 scripts/generate_board.py
```

Ergebnis: [board.svg](board.svg), [board.dxf](board.dxf). Maße und Parameter: [spec.md](spec.md).

## 3. CAM vorbereiten

### Mulden (Quadrate 29×29 mm mit gerundeten Ecken, Tiefe siehe spec)

- **FreeCAD Path**, **Sheetcam**, **Fusion** o. Ä.: `board.dxf` importieren, **nur die Muldenkonturen** (gerundete Quadrate) als **Pocket** / **Inselräumung** mit **6–8 mm** Fräser programmieren.
- Alternativ: generiertes **[gcode/mulden_pockets.ngc](gcode/mulden_pockets.ngc)** in **CAMotics** / **LinuxCNC** prüfen (See-Muldenprofil: außen flacher, innen tiefer; Vorschübe anpassen).

### Koordinaten (1–6 oben + links)

- Ausführliche FreeCAD-Anleitung: **[FREECAD_ZAHLEN_GRAVUR.md](FREECAD_ZAHLEN_GRAVUR.md)** (Path + ShapeString, Alternativen).
- Schnellweg: `gcode/numbers_engrave.ngc` aus dem Script nutzen (einliniger Segment-Font).
- Alternative: SVG enthält **`<text>`**. Viele Postprozessor brauchen **Pfade**:
  - **Inkscape**: Text markieren → **Pfad → Objekt in Pfad umwandeln** → als DXF/SVG erneut exportieren **oder** in CAM nur die Pfade-Gruppe importieren.
- Werkzeug: **Gravierstichel** / schmales **V-Bit**, **sehr flache** Zustellung, Linien **einmal** ohne Überfräsung probieren.

## 4. Empfohlene Fräsreihenfolge

1. Werkstück spannen, **G54** / Null wie gewohnt (z. B. **unten links** Brett, **Z oben** auf Oberfläche).
2. **Mulden** fräsen (Hauptspan).
3. **Zahlen** gravieren (wenig Zustellung, sauberer Rand).

Bei umgekehrter Reihenfolge können **Späne** die Gravur stören oder Kanten ausfransen.

## 5. Simulation / Prüfung

| Werkzeug | Nutzen |
|----------|--------|
| **[CAMotics](https://camotics.org/)** | 3D-Check des **G-Code** (Kollision, Tiefen). |
| **LinuxCNC** | Programm-Vorschau, **Dry-Run** (Spindel aus, langsamer Override, ggf. Z-Offset). |

Details zu **Werkzeugtabelle** (`tool.tbl`): [hardware/cnc/HERSTELLUNG.md](../hardware/cnc/HERSTELLUNG.md) (Abschnitt Werkzeuge – gleiches Prinzip).

## 6. Sicherheit

- Absaugung, Gehörschutz; **Verfahrweg** und **Spannmittel** prüfen.
- Erst **Simulation**, dann **Probebohrung** / **ein Mulde** mit reduziertem Vorschub.

## 7. Glaskiesel separat

Beidseitig gravieren ist **ein anderer Aufspann-Job** (z. B. **Doppelklebeband**-Ring, **Vakuum** mit Schablone, **Z-Null** nach Umdrehen erneut). Liegt **außerhalb** dieser `board.*`-Dateien.
