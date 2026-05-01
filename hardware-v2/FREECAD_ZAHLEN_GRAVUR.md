# Zahlen eingravieren (FreeCAD 1.1.1 + Path)

Du hast das Brett und die **36 Mulden** in **Part Design** – die Zahlen **1–6 oben** und **1–6 links** kommen als **separater CAM-Job** nach den Mulden (siehe [HERSTELLUNG.md](HERSTELLUNG.md), Reihenfolge).

Zwei praktikable Wege:

| Weg | Wann sinnvoll |
|-----|----------------|
| **A) G-Code aus dem Repo** | Schnell, ohne Path-Geometrie für Text |
| **B) FreeCAD Path** | Alles in einem Projekt, Simulation, Postprozessor |

Maße und Positionen der Zentren entsprechen [board.svg](board.svg) / [scripts/generate_board.py](scripts/generate_board.py) (gleiches Raster wie dein Brett).

---

## Weg A: Fertiger Gravur-G-Code (LinuxCNC)

1. Im Repo erzeugen (falls noch nicht geschehen):

   ```bash
   cd hardware-v2
   python3 scripts/generate_board_numbers_ngc.py
   ```

2. Datei **[gcode/numbers_engrave.ngc](gcode/numbers_engrave.ngc)** in LinuxCNC laden.
3. **G54** und **Nullpunkt** müssen zu deinem Brett passen (unten links, Z auf Oberfläche – wie bei den Mulden).
4. **Werkzeug** in `tool.tbl` anlegen (Gravierstichel / V-Bit) und im Programm **T… M6** setzen, falls du Werkzeugwechsel nutzt.
5. **Z-Tiefe** in der NGC ist `Z_ENGRAVE = -0.35` – an Material und Stichel anpassen (Probe auf Restholz).

Hinweis: Die NGC nutzt einen **einfachen Linien-„7-Segment“-Stil** – optisch nicht wie TrueType, dafür CAM-unabhängig.

---

## Weg B: Zahlen in FreeCAD 1.1.1 mit Path (empfohlen für „echte“ Schrift)

### B1. Vorbereitung

1. Speichere dein Brett als **ein Part-Design-Body** mit finaler Oberseite (Mulden fertig).
2. Wechsle zum Arbeitsbereich **Pfad (Path)**.
3. Lege ein **Werkzeug** an (z. B. **Gravierstichel** oder **V-Bit**): Durchmesser / Spitzenwinkel / Länge realistisch eintragen (für V-Bit später die Zustellung aus Vorschub und Tiefe abstimmen).

### B2. Geometrie der Zahlen erzeugen

FreeCAD kann Text als **Draft ShapeString** (Textform) erzeugen, daraus wird für Path meist ein **Draht (Wire)** benötigt.

1. **Ebene wählen:** Eine Skizze auf der **Oberfläche des Bretts** (XY der Oberseite) oder eine **Referenzebene** parallel dazu in der richtigen Höhe (`Z = Brettoberkante`).
2. Menü je nach Version: **Entwurf → Textform / Shape from text** (oder Werkzeugleiste **ShapeString**).
3. Schriftart wählen (TrueType, **fett**), Höhe z. B. **10–12 mm** (Orientierung an `num_size` im OpenSCAD, ca. 0,62 × min(Kopf, Zelle)).
4. Text nacheinander **„1“** … **„6“** für die obere Reihe, dann für die linke Spalte – oder ein String pro Zelle als eigene ShapeString-Instanz, damit du sie einzeln positionieren kannst.

**Position:** Jede ShapeString-Gruppe mit **Platzieren** (`Position` / `Attachment`) so verschieben, dass die Mitte auf den Koordinaten-Zentren liegt (mit Maßband zur Brettkante messen oder Werte aus `board.svg` übernehmen).

**Wire erzeugen (falls Path die Fläche nicht mag):**

- ShapeString markieren → **Teil → Form erstellen** oder **Entwurf → Upgrade** auf Draht / Kantenzug, bis du einen **geschlossenen oder offenen Pfad** hast, den Path als **Gravur** akzeptiert.

### B3. Path-Job anlegen

1. **Pfad → Job erstellen** (auf deinen Brett-Körper / die richtige Basis).
2. **Rohteil (Stock):** entweder aus dem Modell ableiten oder fest **200 × 200 × 18 mm** – wichtig ist, dass die **Null** in Job und Maschine zusammenpassen.
3. **Sicherheitsfläche** (Clearance) z. B. **2–5 mm** über der Oberfläche.

### B4. Gravur-Operation

1. Operation **Gravur (Engrave)** oder **Kontur (Profile)** auf **offene Linien** (je nach FreeCAD-Version und Postprozessor).
2. Kontur wählen: die **Wire/Edges** der Ziffer.
3. **Tiefe / Z-Ende:** z. B. **−0,25 bis −0,5 mm** (erst flach probieren).
4. **Vorschübe:** eher langsam, **Z** noch langsamer als **XY**.

Wenn dein Postprozessor keine echte „Engrave“-Operation hat: **2D-Kontur** mit minimaler seitlicher Zustellung und sehr geringer Tiefe nutzen (entspricht praktisch Gravur).

### B5. Duplizieren auf 12 Ziffern

- Entweder **12 einzelne ShapeStrings** von Hand positionieren (am genauesten),
- oder eine Zeile duplizieren und mit **Entwurf → Array** / **Part Design Muster** (wenn die Geometrie im Body liegt) – bei Path ist oft **manuell 12×** am weniger fehleranfällig.

### B6. Simulation und G-Code

1. **Pfad → Simulator** (falls aktiv) oder Export und **CAMotics**.
2. **Postprozessor** „linuxcnc“ (oder deinen Standard) → **G-Code speichern**.
3. Auf der Maschine: **gleiche G54** wie bei den Mulden.

---

## Typische Stolpersteine

| Problem | Lösung |
|---------|--------|
| Path erkennt den Text nicht | Text in **Wire** umwandeln (siehe B2). |
| Zu viel Material, Stichel bricht | Tiefe halbieren, Vorschub senken. |
| Doppelte Linien bei fetter Schrift | Nur **Außenkontur** der Buchstaben wählen oder Schrift „Outline“-artig wählen. |
| Zahlen spiegeln / falsch orientiert | Achse der ShapeString-Ebene prüfen (Drehung 180° um Z). |

---

## Kurz-Empfehlung

- Willst du **schnell fräsen**: [gcode/numbers_engrave.ngc](gcode/numbers_engrave.ngc) (Weg A).
- Willst du **typografisch schöne Zahlen** wie im Screenshot: **ShapeString + Path Gravur** (Weg B).

Nach dem Gravieren: Oberfläche leicht **entstauben**, ggf. mit **hartem Öl** nachbehandeln (Korn hebt sich nach dem ersten Mal oft etwas).
