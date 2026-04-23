# Schritt-für-Schritt: Koffer und Plättchen herstellen

Diese Anleitung baut auf den Dateien in [hardware/cnc/](README.md) auf. Wichtige Referenzen: [spec.md](spec.md), [case/README.md](case/README.md), [tiles/README.md](tiles/README.md), [field_cam.md](field_cam.md), [layout-buche-mdf.md](layout-buche-mdf.md).

---

## 1. Überblick: Was du in welcher Reihenfolge machst

```text
Vorbereitung (Maße, Werkzeuge, Simulation)
    → Buche: grobe Zuschnitte → CNC Feldtaschen (Boden) → ggf. weiteres Fräsen (Korpus/Deckel)
    → MDF: Register/Dowel-Plan → eine Seite V-Carve → umdrehen → andere Seite → Kacheln ausschneiden
    → Montage: Scharnier, Magnete, Leim/Schrauben für Wände
```

Trenne **Buche-Jobs** und **MDF-Jobs** strikt (Staub, Vorschübe, Werkzeug).

---

## 2. Programme zum Prüfen und Simulieren

| Programm | Wofür es sich eignet | Kosten |
|----------|----------------------|--------|
| **[CAMotics](https://camotics.org/)** | **G-Code** (`.ngc`) 3D-Simulation: Werkzeugweg, Kollisionen mit Rohteil, grobe Zeitschätzung. Sehr sinnvoll für `gcode/spielfeld_pockets.ngc`. | kostenlos, Open Source |
| **LinuxCNC (Axis / gmoccapy / …)** | Eingebaute **Vorschau** des geladenen Programms; **Dry-Run** (Spindel aus, langsamer Override, ggf. Z-Offset). Das ist deine **letzte Prüfung vor der Maschine**. | je nach Setup |
| **[FreeCAD](https://www.freecad.org/)** (Arbeitsbereich **Pfad / Path**) | **2,5D/3D-CAM** aus Skizzen oder importiertem **DXF**; Pocket um geschlossene Konturen; **Werkzeugbibliothek**; Simulation über Path oder Export nach LinuxCNC. Sinnvoll für **Koffer-Geometrie**, **Deckel-Aussparung**, **Scharnier-Nut**, wenn du nicht nur das fertige G-Code aus dem Repo nutzen willst. | kostenlos |
| **[Inkscape](https://inkscape.org/)** | **SVG** bearbeiten, Maßstab **1 mm = 1 Einheit**; PNG-Vorlagen vektorisieren (Plättchen-Motive); Export nach DXF/PDF für CAM. | kostenlos |
| **LibreCAD / QCAD** | **DXF** rein 2D bearbeiten (Layer, Außenkontur, Hilfslinien). | kostenlos bzw. QCAD kommerziell |

**Empfehlung für deinen Ablauf**

1. **Geometrie prüfen:** `spielfeld.svg` in Inkscape öffnen, Maße ablesen (Dokumenteigenschaften mm).
2. **G-Code der Feldtaschen prüfen:** Datei in **CAMotics** laden, Rohteil z. B. 210×210×18 mm anlegen, Nullpunkt wie in [field_cam.md](field_cam.md) beschrieben setzen.
3. **Feintuning CAM:** Wenn du Pocket-Spiralen, bessere Eingriffe oder den **Deckel** programmieren willst: **FreeCAD Path** mit importiertem `spielfeld.dxf` oder eigener Skizze.
4. **Maschine:** LinuxCNC, **Simulation** dort nochmals, dann **Probestück** mit reduziertem Vorschub.

---

## 3. Wo hinterlegst du deine Werkzeuge?

Das hängt davon ab, **wo** du den G-Code erzeugst.

### 3.1 LinuxCNC (an der Fräse)

- Die Maschine kennt Werkzeuge über die **Werkzeugtabelle** (klassisch **`tool.tbl`** im **Konfigurationsordner deiner Maschine**, oft unter `~/linuxcnc/configs/<DEIN_CONFIG_NAME>/`).
- Format: Zeilen mit **T** (Werkzeugnummer), **P** (Pocket), **D** Durchmesser, **Z** Offset Länge usw. – exakt nach der [LinuxCNC-Doku „Tool Table“](http://linuxcnc.org/docs/html/gcode/tool-compensation.html).
- Im **G-Code** rufst du z. B. **`T1 M6`** auf (wenn T1 dein 6-mm-Fräser ist) und musst **dieselbe Nummer** wie in `tool.tbl` verwenden.
- **Wichtig:** Die Zahlen im Repo-G-Code (`spielfeld_pockets.ngc`) setzen **kein** `T1 M6` voraus, du musst den Kopf deines Posts oder die erste Bearbeitungszeile an **deine** Konvention anpassen, sobald du Werkzeugwechsel nutzt.

**Praxis:** Einmal eine **Referenz-Tabelle** anlegen (6 mm Taschenfräser, V-Bit für MDF, Bohrer für Dowels), Backup der `tool.tbl` behalten.

### 3.2 FreeCAD (Path / CAM)

- Werkzeuge liegen in der **Werkzeugtabelle des Path-Arbeitsbereichs** bzw. in **ToolBit-Bibliotheken** (je nach FreeCAD-Version: *Path → Werkzeugverwaltung / ToolBit*).
- Du legst dort z. B. **Endmill 6 mm**, **V-Bit 90°**, **Bohrer 3 mm** mit **Durchmesser**, **Schneidenlänge**, **Spitzenwinkel** (V-Bit) an und weist sie den **Operationen** (Pocket, Profile, Engrave) zu.
- Beim **Postprozessor-Export** (LinuxCNC) erscheinen dann passende **`T…`**-Zeilen, sofern Post und Job so konfiguriert sind.

**Sinn FreeCAD hier:** Koffer-Boden außerhalb des 194×194-Rasters modellieren, **Deckel** mit Parameter (Rahmenbreite), **Nut für Piano-Scharnier** als skizzierte Tasche – und alles mit **derselben** Werkzeugbibliothek.

### 3.3 CAMotics

- Werkzeuge definierst du **im Projekt** (Durchmesser, Länge, Form). Dient der **Simulation**, ersetzt aber **nicht** die LinuxCNC-`tool.tbl`.

### 3.4 Nur Editor / Hand-G-Code

- Werkzeugdaten stehen implizit in den **Kommentaren** und in **deinem Kopf**; die Maschine braucht trotzdem eine konsistente **`tool.tbl`**, sobald du **`G41/G42`** oder **`T… M6`** nutzt.

---

## 4. Vorbereitung (einmalig oder bei Änderung)

1. **[spec.md](spec.md)** lesen: Taschentiefe, Plättchenmaß, Fräsergrößen, Innenhöhe Fach.
2. **[case/README.md](case/README.md)** lesen: Vorschlag Boden **210×210 mm**, Deckel, Fachhöhe, Scharnier.
3. **Scharnier kaufen** (z. B. Piano-Scharnier) und **Abwicklung / Einfräsmaß** aus Datenblatt oder Messung für FreeCAD/Skizze notieren.
4. **Werkzeugtabelle** in LinuxCNC und optional parallel in **FreeCAD** mit deinen echten Fräsern befüllen (s. Abschnitt 3).
5. **Vektoren erzeugen:** Im Projektordner:

   ```bash
   cd hardware/cnc
   python3 scripts/generate_spielfeld.py
   python3 scripts/generate_field_pocket_ngc.py
   ```

---

## 5. Koffer aus Buche (Schritte)

### Schritt 5.1: Rohling vorbereiten

- Material **18 × 200 × 800 mm** laut Plan.
- Mit **Säge** grobe Stücke für **Boden**, **Deckel-Rohling**, **Seitenstreifen** trennen (s. [layout-buche-mdf.md](layout-buche-mdf.md) und [case/README.md](case/README.md) – Längenbudget und Kerf selbst nachmessen).

### Schritt 5.2: Boden – Feldtaschen

1. **Bodenplatte** auf Maschine spannen (oberflächig plan, Z-Null auf **Oberkante**).
2. **XY-Null** legen: empfohlen **untere linke Ecke** des späteren **194×194-Rasters** (wie in [field_cam.md](field_cam.md) / Kommentare in `spielfeld_pockets.ngc`). Wenn dein Boden **210×210** ist: Nullpunkt um **8 mm** versetzen, damit das Raster mittig sitiert, oder Null an Plattenecke und G-Code/G54 verschieben – **ein** System konsequent wählen.
3. **6 mm Fräser** einmessen, **T**-Nummer wählen.
4. G-Code **[gcode/spielfeld_pockets.ngc](gcode/spielfeld_pockets.ngc)** in **CAMotics** prüfen, dann in **LinuxCNC** mit **Dry-Run**.
5. Fräsung starten; **Staubabsaugung**, **Vorschub** bei Bedarf drosseln.

### Schritt 5.3: Korpus-Wände und Fach für Plättchen

- Das ist **kein** fertiges G-Code im Repo – typisch:
  - **FreeCAD:** 3D-Modell Kiste, Außenkonturen und ggf. Taschen für das Plättchenfach als **Path-Job**; Postprocessor → LinuxCNC,  
  - oder **Säge + Handschrauben/Leim** für einfache Rechtecke, Fräse nur für Details (Nut, Griffmulde).

### Schritt 5.4: Deckel „nur Rand“

1. In **FreeCAD** (oder 2D-CAM): Außen **Deckelgröße**, innen große **Tasche** so, dass **Rahmen** und **Rückkante für Scharnier** stehen bleiben (s. [case/README.md](case/README.md)).
2. CAM: mehrstufige Zustellung, großer Fräser für Raum, kleinerer für Schlichten optional.
3. Wieder **CAMotics** / LinuxCNC-Vorschau.

### Schritt 5.5: Scharnier und Verschluss

- **Nut/Anlage** nach **Kaufteil** fräsen oder flach anschrauben (Bauart Scharnier beachten).
- Optional **Magnete** (Senkung, Tiefe so, dass nicht durch den Rand bricht).

### Schritt 5.6: Montage

- Korpus **verleimen** oder **verschrauben** (Vorbohren in Buche).
- **Piano-Scharnier** schrauben, Spiel ausrichten.
- Endkontrolle: Plättchen im Fach, Deckel schließt, keine Kollision mit erhabenem Spielfeld.

---

## 6. Plättchen aus MDF 3 mm (Schritte)

### Schritt 6.1: Platte spannen

- **500×500** MDF flach; **Vacuum**, **Doppelklebeband** auf Spoilerboard oder **Randzwingen** – siehe [tiles/README.md](tiles/README.md).

### Schritt 6.2: Register / Dowels (vor dem Motiv)

- Bohrungen nach **[tiles/doppel-seite.md](tiles/doppel-seite.md)** (Tiefe \< 3 mm, **nicht** durchbohren).
- Optional: gleiche Löcher in **Spoilerboard**, Pins einstecken.

### Schritt 6.3: Erste Seite – V-Carve

1. Motiv: **[tiles/knutt_prototype.svg](tiles/knutt_prototype.svg)** oder **[tiles/muschel_prototype.svg](tiles/muschel_prototype.svg)** – später durch vektorisierte Motive aus `media/` ersetzen.
2. **Inkscape:** SVG auf **25,4×25,4 mm** Kachel legen; für Nest **36×** Positionen laut [layout-buche-mdf.md](layout-buche-mdf.md) (Pitch **28,4 mm**) duplizieren oder in CAM ein **Array** erzeugen.
3. CAM (z. B. **FreeCAD Path** „Gravur“ / Engrave, oder CAM deiner Wahl): **V-Bit** aus Werkzeugbibliothek, **max. Tiefe** 0,35–0,75 mm pro Seite laut [spec.md](spec.md).
4. **Simulation** (FreeCAD Path oder CAMotics nach Post).
5. Fräsen.

### Schritt 6.4: Umdrehen – zweite Seite

1. Werkstück **umdrehen** auf **dieselben Dowels**.
2. **Z-Null** erneut auf neuer Oberfläche antasten.
3. Zweites Motiv fräsen; **XY** muss zum ersten Mal passen (Dowel + asymmetrische Lage).

### Schritt 6.5: Plättchen freischneiden

- **Zuletzt** Außenkontur **25,4×25,4** fräsen oder mit **Gehrungssäge** trennen, damit die dünne Platte beim Gravieren noch steif ist.

---

## 7. Kurz-Checkliste vor dem ersten echten Lauf

- [ ] `tool.tbl` / FreeCAD-Werkzeuge passen zu **D** und **T** im G-Code  
- [ ] Nullpunkte **G54** dokumentiert (Skizze auf Papier)  
- [ ] CAMotics oder LinuxCNC: Bahn sieht **vollständig** aus, **kein** Fräsen in Spannmittel  
- [ ] **MDF:** Absaugung, **Buche:** andere Vorschübe  
- [ ] Not-Aus und **Override** bekannt  

---

## 8. Dateien im Repo (Spickzettel)

| Was | Datei |
|-----|--------|
| Maße / Fräser | [spec.md](spec.md) |
| Kofferlogik | [case/README.md](case/README.md) |
| Nest MDF | [layout-buche-mdf.md](layout-buche-mdf.md) |
| 2D Spielfeld | [spielfeld.dxf](spielfeld.dxf), [spielfeld.svg](spielfeld.svg) |
| Pocket-G-Code | [gcode/spielfeld_pockets.ngc](gcode/spielfeld_pockets.ngc) |
| CAM-Hinweise | [field_cam.md](field_cam.md) |
| Plättchen / Doppelseite | [tiles/README.md](tiles/README.md), [tiles/doppel-seite.md](tiles/doppel-seite.md) |

Bei abweichender **Zellgröße** zuerst `scripts/generate_spielfeld.py` und `spec.md` anpassen, Skripte erneut laufen lassen, dann CAM neu erzeugen.
