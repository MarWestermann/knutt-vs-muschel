# Zuschnitt: Buche 18 × 200 × 800 mm und MDF 500 × 500 × 3 mm

Siehe [spec.md](spec.md) für Raster- und Plättchenmaße.

## Buche 200 × 800 (Draufsicht, nur Planidee)

Der **eine** Rohling liefert mehrere Teile; exakte Längen hängen von **Koffer-Außenmaß**, **Fachhöhe** und **Säge-/Fräsradius** ab. Reihenfolge: große Pockets (Spielfeld im Boden), dann große Außenkonturen, zuletzt kleine Teile.

| Teil | Rolle | Richtung |
|------|--------|----------|
| Bodenplatte | 6×6-Taschen, mind. **194 × 194** Raster + **Korpuswand** ringsum (Maße aus [case/README.md](case/README.md)) | aus Streifen schneiden |
| Deckel | Ausgehöhlt, **Rand** für Scharnier/Verschluss | eigener Zuschnitt |
| Wände / Lamellen | Innenhöhe Plättchenfach **> 18 mm** → **mehrere** Streifen aus 800 mm oder gestapelte Seiten | siehe case |

**Spielfeld-Außenrechteck** (nur Taschen): **194 × 194 mm** – im Boden zentrieren oder mit definierter Offset-Kante zum Kofferinnenmaß planen.

## MDF 500 × 500 – 36 Plättchen nesten

| Parameter | Wert |
|-----------|------|
| Plättchen | **25,4 × 25,4 mm** (Nenn), Dicke **3 mm** |
| Raster im Nest | 6 Spalten × 6 Zeilen |
| Pitch (Mitte–Mitte oder Kante–Kante + Spalt) | Kante–Kante **25,4** + **Spalt 3 mm** zwischen Plättchen → **28,4 mm** Raster |
| Block 6×6 | `6 × 25,4 + 5 × 3 = 167,4 mm` Kantenlänge |
| Rand auf 500×500 | großzügig für **Spoilerboard**, **Schraub-Inseln**, **Vacuum** |

Zentrierung auf der Platte: z. B. Urspriff links unten `(10, 10)` mm, dann Rechtecke `25,4 × 25,4` in einem Gitter mit Schritt **28,4 mm**.

Motiv-V-Carve: **Dowels / Register** in den **Ecken** des 500×500 oder in **Verschnitt** legen, nicht im Motiv (s. [tiles/doppel-seite.md](tiles/doppel-seite.md)).
