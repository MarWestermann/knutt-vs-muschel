import 'package:flutter/material.dart';

import '../engine/rules.dart';
import '../engine/types.dart';

class PlayerPanel extends StatelessWidget {
  const PlayerPanel({
    super.key,
    required this.board,
    required this.current,
    required this.gameOver,
    required this.skipRounds,
  });

  final Board board;
  final TileKind current;
  final bool gameOver;
  final int skipRounds;

  @override
  Widget build(BuildContext context) {
    final kn = countTiles(board, TileKind.knutt);
    final ms = countTiles(board, TileKind.muschel);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Population', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _row(
              active: !gameOver && current == TileKind.knutt,
              asset: 'assets/knutt.png',
              label: 'Knutt',
              count: kn,
            ),
            const SizedBox(height: 6),
            _row(
              active: !gameOver && current == TileKind.muschel,
              asset: 'assets/muschel.png',
              label: 'Herzmuschel',
              count: ms,
            ),
            const SizedBox(height: 10),
            Text(
              gameOver
                  ? 'Spiel beendet'
                  : 'Am Zug: ${current == TileKind.knutt ? 'Knutt (Räuber)' : 'Herzmuschel (Beute)'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (skipRounds > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Pause Herzmuschel-Vermehrung: $skipRounds',
                  style: TextStyle(color: Colors.brown.shade700, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required bool active,
    required String asset,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? const Color(0xFF008B8B) : Colors.transparent,
          width: 2,
        ),
        color: active ? const Color(0x14008B8B) : null,
      ),
      child: Row(
        children: [
          Image.asset(asset, width: 32, height: 32),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
    );
  }
}
