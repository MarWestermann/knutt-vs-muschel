# hardware-v2: 200×200 Spielfeld für Glaskiesel

Fertigung nur des **Spielbretts** (Mulden + Koordinatengravur). **Kein** Koffer, **keine** MDF-Plättchen.

- **Spezifikation:** [spec.md](spec.md)
- **Schritte / Simulation:** [HERSTELLUNG.md](HERSTELLUNG.md)
- **Vektoren:** [board.svg](board.svg), [board.dxf](board.dxf) (regenerierbar)
- **Optional G-Code-Mulden:** [gcode/README.md](gcode/README.md)

## Regenerieren

```bash
cd hardware-v2
python3 scripts/generate_board.py
python3 scripts/generate_board_mulden_ngc.py
```

## Legacy (v1)

Koffer + MDF-Plättchen: [hardware/cnc/](../hardware/cnc/).
