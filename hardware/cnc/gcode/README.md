# G-Code-Vorlagen (LinuxCNC)

| Datei | Inhalt |
|-------|--------|
| [spielfeld_pockets.ngc](spielfeld_pockets.ngc) | 36 Feldtaschen, regenerieren mit `python3 ../scripts/generate_field_pocket_ngc.py` (aus `hardware/cnc/`). |

Vor dem ersten Lauf: **G54**, **Werkzeuglänge**, **Spindel**, **Sicherheits-Z** und **Vorschübe** an die Maschine anpassen. **Simulation** oder **Dry-Run** zuerst.
