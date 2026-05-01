# Herzmuschel-Stempel (FreeCAD)

Vektor-Vorlage einer stilisierten Herzmuschel (Cardium edule) zum Bau eines
Stempels per CNC oder 3D-Druck.

## Dateien

| Datei | Inhalt | Empfohlen fuer |
|-------|--------|----------------|
| [herzmuschel.svg](herzmuschel.svg) | Aussenkontur + 17 Rippen + Umbo | Linien-Stempel (Rippen + Kontur erhaben) |
| [herzmuschel-outline.svg](herzmuschel-outline.svg) | Nur Aussenkontur | Silhouetten-Stempel (Vollflaeche) |
| [scripts/generate_herzmuschel.py](scripts/generate_herzmuschel.py) | Generator (parametrisch) | Anpassung Groesse / Rippen |

Bbox der Muschel: **50 × 46 mm** (parametrisierbar im Script).

## Regenerieren

```bash
cd hardware-v2
python3 scripts/generate_herzmuschel.py
```

Wichtige Parameter im Script (Kopfbereich):

- `WIDTH`, `HEIGHT` — Gesamtmasse der Muschel
- `N_RIBS`, `RIB_FAN_DEG` — Anzahl und Faecheroeffnung der Rippen
- `RIB_INSET` — Abstand der Rippen-Spitzen zur Aussenkontur (Sicherheit)
- `UMBO_R` — Groesse des Buckels oben

## FreeCAD: SVG zu Stempel

### Variante A — Silhouetten-Stempel (positiv erhaben)

Das Motiv ist eine geschlossene Flaeche, die als Block aus der Stempelplatte
herausragt.

1. **Datei → Importieren** → `herzmuschel-outline.svg`
   (Workbench **Draft** muss aktiv sein, oder im Importdialog "SVG als Geometrie".)
2. Die importierten Pfade markieren → **Draft → Draft to Sketch** (oder
   **Sketcher → Sketch aus Auswahl konvertieren**), um eine bemassbare Skizze
   zu erhalten.
3. **Part Design**: Body anlegen → die Skizze als **Pad** mit Hoehe **3–5 mm**
   (Stempelflaeche) auspressen.
4. Stempelkoerper (z. B. ein **Pad** 60 × 56 × 15 mm) erstellen und das
   Motiv-Pad **darauf addieren** (Boolean Union) oder direkt im Body als zweites
   Pad fuehren.
5. Optional Griff (Cylinder o. Aehnliches) oben anbringen.

### Variante B — Linien-Stempel (Kontur + Rippen erhaben)

Klassischer Druckstempel: nur Kontur und Rippen sind erhaben, der Rest ist
weggefraest.

1. **Datei → Importieren** → `herzmuschel.svg`.
2. Pfade markieren → **Draft → Draft to Sketch**.
3. Die **Aussenkontur** als geschlossenen Pfad in eine Skizze packen, **Pad**
   z. B. **2 mm** (= Stegbreite der Linie). Vorher in der Skizze die Linie als
   **dicken Steg** offsetten (Draft → Versetzte Kopie / Sketcher → Offset),
   damit die Linie eine Breite hat. Empfehlung: **0.6–0.8 mm** Stegbreite,
   sonst bricht der Holzsteg beim Stempeln.
4. Fuer die **Rippen** das gleiche Vorgehen: Linien zu duennen Rechtecken
   offsetten und als **Pad** (gleiche Hoehe wie Kontur) hinzufuegen.
5. Stempelkoerper (Block) darunter, alles vereinen.

> Tipp: Statt manuellem Offset in FreeCAD kann der Generator auch erweitert
> werden, sodass die Rippen direkt als duenne **geschlossene** Wedges (statt
> Linien) im SVG stehen. Dann entfaellt Schritt 3/4-Offset.

### Variante C — Negativ-Form (Praegestempel)

Wenn der Stempel **eindrueckt** statt aufzudrucken (z. B. fuer Wachs oder Ton):

1. Wie Variante A vorgehen, aber statt **Pad** ein **Pocket** auf den
   Stempelkoerper legen → Tiefe **1–2 mm**.
2. Aussenkontur muss sauber geschlossen sein (Catmull-Rom-Pfad ist es).

## CNC / Material

| Parameter | Empfehlung |
|-----------|------------|
| Material | Hartholz (Buche, Birne) **oder** PLA/Resin (3D-Druck) |
| Stempel-Reliefhoehe | **2–4 mm** |
| Stegbreite Linien-Stempel | **0.6–0.8 mm** (Holz), ab **0.4 mm** (Resin) |
| Werkzeug Kontur (CNC) | **1 mm** Schaftfraeser oder **30°-V-Bit** |
| Werkzeug Rippen (CNC) | **30–60° V-Bit** Gravur |
| Werkzeug Flaechenraeumung | **3–6 mm** Schaftfraeser, **1–2 mm** Zustellung |

## Handgriff fuer den Stempel

Optional separater Holzgriff oder direkt im Body als Cylinder oben:
- **Ø 25 mm**, **Hoehe 60 mm**, oben abgerundet (Fillet 12 mm).

## Bestehende Datei

Es gibt bereits `muschel-stempel.FCStd` (leeres Geruest) — die generierte SVG
laesst sich direkt dort hinein importieren.
