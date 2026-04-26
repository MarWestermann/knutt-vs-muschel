# G-Code (hardware-v2)

| Datei | Beschreibung |
|-------|----------------|
| [mulden_pockets.ngc](mulden_pockets.ngc) | **Vorlage** für **36 See-Mulden** in **quadratischer Form mit gerundeten Ecken**: gestaffelte Innenkonturen mit radialer Tiefenstaffelung (außen flach, innen tiefer), Werkzeug **Ø 6 mm** angenommen. |
| [numbers_engrave.ngc](numbers_engrave.ngc) | Gravur der **Zahlen 1–6 oben und links** (separater Job, 7-Segment-Linienfont, Gravierstichel/V-Bit). |

Erzeugen:

```bash
cd hardware-v2
python3 scripts/generate_board_mulden_ngc.py
python3 scripts/generate_board_numbers_ngc.py
```

**Hinweis:** Das Profil ist auf „**flacher See**“ ausgelegt (langsam tiefer zur Mitte). Für noch glattere 3D-Flächen ist ein CAM-Job mit **Kugelfräser + 3D-Parallelbahnen** in FreeCAD/Fusion meist besser. Diese Datei dient als **schneller Startpunkt**; `G54`, **Spindel**, **T**/`tool.tbl` und **Vorschübe** vor dem Lauf anpassen.

Koordinaten-Gravur ist als G-Code verfügbar (`numbers_engrave.ngc`). Alternativ weiter über CAM aus **Pfaden** (Inkscape „Text in Pfad“).
