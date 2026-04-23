import 'package:flutter/material.dart';

class RulesSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spielregeln',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Zwei Spieler:innen wechseln sich ab. Der erste Würfel bestimmt die Spalte (x), '
                  'der zweite die Zeile (y) – jeweils 1 bis 6.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Knutt (Jäger): frisst Herzmuschel auf dem Ziel und vermehrt sich (zweites Knutt auf '
                  'freies Nachbarfeld). Leeres Feld oder Knutt auf dem Ziel: ein Knutt verhungert.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Herzmuschel (Beute): vermehrt sich auf leeres Ziel oder Nachbarfeld. Auf Knutt: '
                  'wird gefressen, neues Knutt auf Nachbarfeld.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Volles Spielfeld: Herzmuschel-Vermehrung ist 5 Züge lang eingeschränkt (Pause-Zähler).',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Einwanderung: Ist eine Art ausgestorben, erscheint wieder ein Plättchen auf einem freien Feld.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ende: Nach 20 Protokollpunkten (je alle 10 Runden) oder spätestens nach 200 Würfen.',
                ),
                const SizedBox(height: 10),
                Text(
                  'Ausführliche Fassung: docs/spielregeln.md im Repository.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
