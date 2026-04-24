# G-Code (hardware-v2)

| Datei | Beschreibung |
|-------|----------------|
| [mulden_pockets.ngc](mulden_pockets.ngc) | **Vorlage** für **36 Mulden**: konzentrische Kreise in Z-Schichten, Werkzeug **Ø 6 mm** angenommen. |

Erzeugen:

```bash
cd hardware-v2
python3 scripts/generate_board_mulden_ngc.py
```

**Hinweis:** Für saubere **flache Muldenböden** und kürzere Laufzeiten ist CAM mit **Spiral-Pocket** meist besser als diese reine Kreis-Vorlage. Datei dient **Simulation** (CAMotics) und als **Startpunkt**; `G54`, **Spindel**, **T**/`tool.tbl` und **Vorschübe** vor dem Lauf anpassen.

**Koordinaten-Gravur** liegt nicht als G-Code vor – über CAM aus **Pfaden** (Inkscape „Text in Pfad“) erzeugen.
