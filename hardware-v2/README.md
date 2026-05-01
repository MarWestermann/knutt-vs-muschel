# hardware-v2: 200×200 Spielfeld für Glaskiesel

Fertigung nur des **Spielbretts** (Mulden + Koordinatengravur). **Kein** Koffer, **keine** MDF-Plättchen.

- **Spezifikation:** [spec.md](spec.md)
- **Schritte / Simulation:** [HERSTELLUNG.md](HERSTELLUNG.md)
- **FreeCAD: Zahlen gravieren:** [FREECAD_ZAHLEN_GRAVUR.md](FREECAD_ZAHLEN_GRAVUR.md)
- **Herzmuschel-Stempel:** [HERZMUSCHEL_STEMPEL.md](HERZMUSCHEL_STEMPEL.md), [herzmuschel.svg](herzmuschel.svg), [herzmuschel-outline.svg](herzmuschel-outline.svg)
- **Vektoren:** [board.svg](board.svg), [board.dxf](board.dxf) (regenerierbar)
- **3D-Modell:** [board.scad](board.scad) (OpenSCAD, parametrisch)
- **Optional G-Code-Mulden:** [gcode/README.md](gcode/README.md)

## Regenerieren

```bash
cd hardware-v2
python3 scripts/generate_board.py
python3 scripts/generate_board_mulden_ngc.py
python3 scripts/generate_board_numbers_ngc.py
python3 scripts/generate_herzmuschel.py
```

## Legacy (v1)

Koffer + MDF-Plättchen: [hardware/cnc/](../hardware/cnc/).
