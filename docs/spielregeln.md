# Knutt vs. Herzmuschel – Spielregeln

Digitale Adaption des Unterrichtsspiels „Marienkäfer und Blattläuse“ (Räuber–Beute).  
**Räuber:** Knutt · **Beute:** Herzmuschel

## Material

- Spielfeld 6×6 (Koordinaten 1–6 waagerecht, 1–6 senkrecht)
- 36 doppelseitige Plättchen (hier: digitale Darstellung pro Zelle)
- Zwei Würfel (je 1–6): erster Würfel = waagerechte Achse (Spalte), zweiter = senkrechte Achse (Zeile)
- Zwei Spieler:innen (Hot-Seat) – abwechselnd würfeln

## Startaufstellung

- 10 Herzmuschel-Plättchen und 5 Knutt-Plättchen werden **zufällig** auf freie Felder verteilt.

## Spielablauf

Die Spieler:innen würfeln abwechselnd. Aus den Würfeln ergibt sich das Zielfeld \((x, y)\) mit \(x, y \in \{1,\ldots,6\}\).

### Knutt (Räuber) ist am Zug

| Zielfeld enthält | Wirkung |
|------------------|---------|
| **Herzmuschel** | Knutt nimmt das Feld ein (Fressen). Auf dem Zielfeld liegt nun ein Knutt-Plättchen. Zusätzlich erscheint ein weiteres Knutt-Plättchen auf einem **zufälligen freien Nachbarfeld** (8-Nachbarschaft inkl. Diagonalen) – **Vermehrung**. Gibt es kein freies Nachbarfeld, entfällt die Vermehrung. |
| **Knutt oder leer** | Die Knutt-Population verliert ein Plättchen (**Verhungern**). Enthält das Zielfeld einen Knutt, wird dieser entfernt (Feld leer). Ist das Zielfeld leer, wird ein **zufälliges** Knutt-Plättchen vom gesamten Spielfeld entfernt. |

### Herzmuschel (Beute) ist am Zug

| Zielfeld enthält | Wirkung |
|------------------|---------|
| **Leer oder Herzmuschel** | Es kommt ein weiteres Herzmuschel-Plättchen hinzu (**Vermehrung**): zuerst auf dem Zielfeld, falls leer; sonst auf einem **zufälligen freien Nachbarfeld**. Gibt es keines, entfällt die Vermehrung. |
| **Knutt** | Das Herzmuschel-Plättchen wird „gefressen“: Es entsteht ein Knutt-Plättchen, das auf ein **zufälliges freies Nachbarfeld** gelegt wird. Das Zielfeld wird **leer**. |

### Vollständig besetztes Spielfeld

Sind alle 36 Felder belegt, können sich Herzmuscheln nicht weiter vermehren. Dann gilt: **5 aufeinanderfolgende Züge der Herzmuschel-Spielerin** – bei Zügen, die eine **Vermehrung** der Herzmuscheln bewirken würden, entfällt diese stattdessen und der Pausenzähler sinkt (siehe Implementierung im Spiel).

### Ausgestorbene Population

Ist eine der beiden Arten **vor** der Einwanderungsregel nicht mehr auf dem Feld, wird **ein** Plättchen dieser Art auf ein **zufälliges leeres** Feld gelegt (**Einwanderung**).

## Protokoll (wie im Original)

Nach jeweils **10 Würfelrunden** werden die Anzahlen der Knutt- und Herzmuschel-Plättchen notiert – insgesamt **20 Mal** (also bis ca. **400** Würfe).

## Hinweise zur digitalen Umsetzung

- **Nachbarfeld:** 8 Nachbarn (orthogonal + diagonal).
- Zufallswerte sind für Tests **seedbar** (deterministische Engine).
