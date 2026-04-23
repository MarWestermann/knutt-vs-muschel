# Phase 2: Flutter-Portierung (Skizze)

Ziel: dieselbe Spiellogik und Assets wie in [`web/`](../web/) als native **Flutter**-App unter z. B. `mobile/`.

## 1. Projekt anlegen

```bash
cd knutt-vs-muschel
flutter create mobile --org com.example.knutt_vs_muschel
```

## 2. Assets

In `pubspec.yaml`:

```yaml
flutter:
  assets:
    - ../media/spielfeld.png
    - ../media/knutt.png
    - ../media/muschel.png
```

(Pfade ggf. an Monorepo-Struktur anpassen oder Assets nach `mobile/assets/` kopieren.)

## 3. Spiellogik

- Referenz: [`web/src/engine/`](../web/src/engine/) (reine Funktionen, kein Framework).
- In Dart portieren: `Board`, `GameState`, `applyMove`, `createInitialState`, `rollDie`, Tests mit `package:test`.
- **RNG:** denselben Algorithmus (Mulberry32) oder `Random(seed)` mit dokumentierter Abweichung.

## 4. State Management

- **Riverpod** oder **Provider**: Zustand analog zu [`web/src/stores/game.ts`](../web/src/stores/game.ts) (`newGame`, `rollDice`, `lastDice`, `rolling`).

## 5. UI

- `GridView` / `Stack` mit Hintergrund `spielfeld.png` und überlagertem 6×6-Grid (ähnliche Insets wie in `Board.vue`).
- Würfel: `AnimatedSwitcher` oder kurze Rotation.
- Diagramm: **`fl_chart`** (Liniendiagramm) anhand von `snapshots`.

## 6. Qualität

- Widget-Tests für Startaufstellung (10 + 5 Plättchen).
- Unit-Tests der Rules (Kopie der Vitest-Szenarien).

## 7. Veröffentlichung

- Android: Play Console, iOS: App Store Connect (Icons, Screenshots aus dem Spielfeld).

Damit bleiben Web und Mobile fachlich deckungsgleich; Änderungen an Regeln zuerst in der TypeScript-Engine festhalten und dann nach Dart übernehmen.
