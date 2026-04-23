# Knutt vs. Herzmuschel (Flutter)

Native App (Android / iOS) mit derselben Spiellogik wie [`../web/`](../web/).

## Voraussetzungen

- [Flutter](https://flutter.dev) (SDK inkl. Dart), empfohlen: aktueller **stable**-Channel

## Befehle

```bash
cd mobile
flutter pub get
flutter run          # Gerät oder Emulator wählen
flutter test         # Engine- + Widget-Tests
flutter build apk    # Release-APK (Android)
```

## Struktur

| Pfad | Inhalt |
|------|--------|
| `lib/engine/` | Frameworkfreie Spielregeln (Port von `web/src/engine/`) |
| `lib/state/` | Riverpod `StateNotifier` (Spiel + Simulation) |
| `lib/widgets/` | UI (Board, Würfel, Diagramm, Tabs) |
| `assets/` | `knutt.png`, `muschel.png` (Kopie aus `../media/`) |

## Hinweis

Die Spielfeld-Grafik `spielfeld.png` wird in der App nicht als Hintergrund genutzt; das Brett ist wie in der Web-Variante in **Widgets** nachgebaut (7×7-Grid mit Headern).
