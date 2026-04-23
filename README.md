# Knutt vs. Herzmuschel

Räuber–Beute-Spiel (Unterrichtsmaterial adaptiert): **Knutt** jagt **Herzmuschel** auf einem 6×6-Spielfeld.

- **Regeln:** [docs/spielregeln.md](docs/spielregeln.md) · Original-PDF in `docs/`
- **Medien:** `media/` (Spielfeld, Sprites)
- **Web-App:** `web/` (Vue 3, TypeScript, Vite, Pinia, Chart.js, Vitest)
- **Mobile (Plan):** [docs/FLUTTER_PORTIERUNG.md](docs/FLUTTER_PORTIERUNG.md)

## Web lokal starten

```bash
cd web
npm install
npm run dev
```

Build:

```bash
npm run build
npm run preview
```

Tests (Spiellogik):

```bash
npm run test
```

## Spielweise

Zwei Spieler:innen am selben Gerät (**Hot-Seat**). Abwechselnd würfeln: erster Würfel = Spalte **x**, zweiter = Zeile **y** (jeweils 1–6). Nach jedem Wurf wechselt die aktive Spezies automatisch.
