import 'package:flutter_test/flutter_test.dart';
import 'package:knutt_vs_muschel/engine/rules.dart';
import 'package:knutt_vs_muschel/engine/types.dart';
import 'package:knutt_vs_muschel/engine/simulator.dart';

void main() {
  test('simulateFullGame: Invarianten über viele Seeds', () {
    for (var seed = 0; seed < 100; seed++) {
      final s = simulateFullGame(seed);
      expect(s.snapshots.length, lessThanOrEqualTo(20));
      final k = countTiles(s.board, TileKind.knutt);
      final m = countTiles(s.board, TileKind.muschel);
      expect(k, greaterThanOrEqualTo(0));
      expect(m, greaterThanOrEqualTo(0));
      expect(k + m, lessThanOrEqualTo(36));
      expect(s.gameOver, isTrue);
    }
  });
}
