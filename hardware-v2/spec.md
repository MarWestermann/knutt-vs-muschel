# hardware-v2: 200×200 Spielfeld (Glaskiesel)

## Ziel

- **Nur Brett**: **200 × 200 mm** Außenmaß, **kein** Koffer/Deckel.
- **6×6 Mulden** für Glaskiesel **Ø ca. 28 mm** (Mulde etwas größer).
- **Koordinaten 1–6** oben (Spalten **x**) und links (Zeilen **y**), **Ecke oben-links leer** – gemäß [media/spielfeld-original.png](../media/spielfeld-original.png).

## Rohling

- **Buche 18 × 200 × 800 mm** (wie bisher): mehrere **200×200**-Teile aus der Länge **800 mm** planen (Sägekerf einrechnen).

## Layout (berechnet)

Verhältnis wie [web/src/components/Board.vue](../web/src/components/Board.vue): Kopfzeile/-spalte **0,55 fr**, Spielfeld **1 fr** je Zelle, dazwischen **konstanter Spalt** zwischen allen Bandstreifen.

| Parameter | Wert |
|-----------|------|
| Außenmaß | **200 × 200 mm** |
| Spalt `GAP` zwischen Bandstreifen | **1,2 mm** |
| Verhältnis Kopf / Spielfeldzelle | **0,55** (`h = 0,55 × c`) |
| Spielfeldzelle `c` | **≈ 29,435 mm** (Skriptausgabe) |
| Kopfband `h` | **≈ 16,189 mm** |
| Mulde (quadratisch, gerundete Ecken) | **29,0 × 29,0 mm** |
| Eckenradius Mulde `MULDE_CORNER_R` | **4,8 mm** |
| Muldentiefe (Richtwert) | **2,5–4,0 mm** bei **18 mm** Brettdicke; Restboden **≥ ca. 12 mm** |

Die Zahlen `c` und `h` leiten sich aus `h + 6·c + 6·GAP = 200` und `h = 0,55·c` ab. Änderungen nur im Skript [scripts/generate_board.py](scripts/generate_board.py) und hier dokumentieren.

## Werkzeuge (Richtwerte)

| Aufgabe | Werkzeug |
|---------|----------|
| Mulden (quadratische Tasche mit Rundungen) | **6–8 mm** HM-Torus/Schaft; CAM als Pocket/2.5D, Eckenradius im Pfad erhalten |
| Mulde „schüsselförmig“ (optional) | **Kugelfräser** – separates CAM, flacher |
| Zahlen 1–6 | **Gravierstichel** / V-Bit sehr flach; in CAM **Gravur** oder **einlinige** Pfade |

## Fräsreihenfolge (empfohlen)

1. **Grober Nullpunkt** (oben/links Außenkante oder Mitte – ein System wählen und dokumentieren).
2. **Mulden** fräsen (Span, evtl. vorher grob planfräsen).
3. **Koordinaten gravieren** (oberflächlich, sauberer Rand).

**Hinweis:** SVG liefert Zahlen oft als `<text>`. Viele CAM-Programme brauchen **Pfade** – in Inkscape: Schrift in Pfad umwandeln (s. [HERSTELLUNG.md](HERSTELLUNG.md)).

## Legacy

Ältere Planung (Koffer, MDF-Plättchen): [hardware/cnc/README.md](../hardware/cnc/README.md).
