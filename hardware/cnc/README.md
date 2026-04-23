# CNC-Holzvariante (Koffer + Spielfeld + Plättchen)

Physische Umsetzung des 6×6-Spiels aus [docs/spielregeln.md](../../docs/spielregeln.md): **Buche** für Koffer und Spielfeld, **MDF 3 mm** für 36 doppelseitige Plättchen. CAM-Ziel: **LinuxCNC** (Volksfräse).

## Inhalt dieses Ordners

| Pfad | Beschreibung |
|------|----------------|
| **[HERSTELLUNG.md](HERSTELLUNG.md)** | **Ausführliche Schrittfolge** Koffer + Plättchen, **Simulation**, **FreeCAD**, **Werkzeugtabellen** |
| [spec.md](spec.md) | Material, Raster, Plättchenmaße, Taschentiefe, Fräserliste |
| [layout-buche-mdf.md](layout-buche-mdf.md) | Zuschnitt Buche 800 mm, Nest 36× auf MDF 500×500 |
| [spielfeld.svg](spielfeld.svg) / [spielfeld.dxf](spielfeld.dxf) | 6×6-Taschen + Außenkontur **194×194 mm** |
| [field_cam.md](field_cam.md) | Pocket-CAM, Simulation, DXF-Alternative |
| [scripts/](scripts/) | `generate_spielfeld.py`, `generate_field_pocket_ngc.py` |
| [gcode/](gcode/) | `spielfeld_pockets.ngc` (Vorlage) |
| [tiles/](tiles/) | V-Carve-Prototyp-SVGs, Doppelseite, Nest-Hinweise |
| [case/](case/) | Koffer: getrennte Teile, Scharnier, Innenmaße, Zuschnitt |

## Sicherheit und Gesundheit

- **Augen-/Gehörschutz**; lose Kleidung und Langhaar sichern.
- **Spannmittel** und **Verfahrweg** prüfen (Gantry, Kollision Werkstück / Schraubzwinge).
- **MDF** erzeugt feinen Staub – **Absaugung** am Werkzeug, Raum lüften; getrennte Vorschübe für MDF vs. Buche.
- Erst **Simulation** / **Dry-Run**, dann mit Override langsam **Probestück**.

## LinuxCNC-Workflow (kurz)

1. Vektoren / CAD: `spielfeld.dxf` oder SVG nachbearbeiten.
2. CAM oder generiertes G-Code: [gcode/spielfeld_pockets.ngc](gcode/spielfeld_pockets.ngc).
3. **G54** setzen, **Werkzeuglängenmessung**, **Spindel**-Drehzahl laut Werkzeug/Holz.
4. **Buche**- und **MDF**-Jobs getrennt fahren (Werkzeugwechsel, Vorschübe).

## Regenerieren (Vektoren + G-Code)

```bash
cd hardware/cnc
python3 scripts/generate_spielfeld.py
python3 scripts/generate_field_pocket_ngc.py
```

Maße ändern: zuerst Konstanten in `scripts/generate_spielfeld.py` und [spec.md](spec.md) abstimmen, dann Skripte erneut ausführen.
