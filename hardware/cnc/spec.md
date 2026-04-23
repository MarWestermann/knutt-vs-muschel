# CNC-Holzvariante – technische Spezifikation

Referenz: [docs/spielregeln.md](../../docs/spielregeln.md) (6×6, 36 Plättchen).  
Bildreferenz nur für Motive: `media/spielfeld.png`, `media/knutt.png`, `media/muschel.png`.

## Material (fest)

| Teil | Material | Rohling | Hinweis |
|------|----------|---------|---------|
| Koffer inkl. Spielfeld | Buche Vollholz | **18 × 200 × 800 mm** | Getrennte Zuschnitte (Boden, Deckel, Wände); Verbindung **Scharnier** (s. [case/README.md](case/README.md)). |
| 36 Plättchen | MDF | **500 × 500 × 3 mm** | Separates Blatt; Nest siehe [layout-buche-mdf.md](layout-buche-mdf.md). |

## Feldtaschen (Buche-Boden)

| Parameter | Wert | Anmerkung |
|-----------|------|-----------|
| Taschentiefe Ziel | **9,5 mm** | Unter „ca. 10 mm“; Restboden ≈ **8,5 mm** bei 18 mm Brettdicke. |
| Alternative | 8–9 mm | Bei unsicherem Aufspannen / aggressiver Zustellung. |
| Stegbreite | **6 mm** | Abgestimmt auf **6 mm Vollhartmetall-Torus** für Taschen (siehe Fräserliste). |

## Raster ↔ Plättchen (gebunden)

Alle Maße in **Millimeter**. Koordinaten Spielfeld wie im Spiel: Spalte 1–6 (x), Zeile 1–6 (y).

| Parameter | Wert |
|-----------|------|
| Nutzbare Taschen-Innenbreite / -länge je Feld | **26,0 × 26,0** |
| Steg zwischen Taschen | **6,0** |
| Rand zum Außenrechteck Spielfeld | **4,0** je Seite |
| **Außenmaß Spielfeld-Rechteck** (nur Raster, ohne Kofferwand) | **194 × 194** |

Berechnung: `2×4 + 6×26 + 5×6 = 194`.

| Parameter | Wert |
|-----------|------|
| **Plättchen-Nennmaß** (MDF, liegend im Fach) | **25,4 × 25,4 × 3,0** |
| Zugabe zur Tasche | **0,6 mm** gesamt (0,3 mm je Seite) – leichtes Einlegen |

Bei anderer Zellgröße: `spec.md` und `scripts/generate_spielfeld.py` anpassen, Vektoren neu erzeugen (`python3 scripts/generate_spielfeld.py`).

## Plättchen-Stapel → Koffer-Innenhöhe

| Parameter | Wert |
|-----------|------|
| Theorie 36 × 3 mm | 108 mm |
| Empfohlenes **Innenmaß Fach** (Höhe) | **120–125 mm** | Luft, schiefes Einlegen, MDF-Toleranz. |

## Relief MDF (pro Seite)

| Variante | Gesamttiefe pro Seite (Richtwert) |
|----------|-----------------------------------|
| A (empfohlen): V-Carve / flache Gravur | **0,35–0,75 mm** |
| B: Heightmap-3D | nur bei sehr geringer Zustellung; Durchbruch vermeiden |

## Fräserliste (Richtwerte)

Anpassen an Maschine, Werkzeugbestand und Holzfeuchte. **Eigene Vorschübe** für Buche vs. MDF.

| Aufgabe | Werkzeug | Notiz |
|---------|----------|------|
| Taschen 6×6, Stege 6 mm | **6 mm HM-Torus** (oder 6 mm Schaftfräser mit Ecken anpassen) | Pocket CAM; ggf. Werkzeugradiuskorrektur / Hundeknochen in CAM. |
| Außenkontur Koffer / Zuschnitt | **6 mm** oder Säge | Letzte Op nach Taschen. |
| Deckel aushöhlen | **6–8 mm** | Große Restmaterialfläche; Schlichtgang optional. |
| Scharnier-Nut / Verschluss | **kleiner Schaft** oder Nutfräser | Maße vom **gekauften** Scharnier übernehmen. |
| MDF Plättchen Relief | **V-Nutfräser** (z. B. 90° oder 60°) + ggf. **1–3 mm** zum Schlichten | Sehr flache Zustellung, Absaugung. |
| Dowel-Register (MDF) | **3 mm** oder **4 mm** Bohrer | Tiefe \< Plättchendicke; **nicht** durchbohren. |

## LinuxCNC

- Metrisch, Maschinennull und Werkzeuglängenmessung wie an der Volksfräse üblich.
- `gcode/`-Vorlagen sind **Startpunkte**: Koordinaten, `G54`, Sicherheitshöhen und Vorschübe vor dem ersten Lauf prüfen.
