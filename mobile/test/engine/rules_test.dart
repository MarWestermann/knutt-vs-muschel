import 'package:flutter_test/flutter_test.dart';
import 'package:knutt_vs_muschel/engine/rules.dart';
import 'package:knutt_vs_muschel/engine/rng.dart';
import 'package:knutt_vs_muschel/engine/setup.dart';
import 'package:knutt_vs_muschel/engine/types.dart';

Board boardFromStrings(List<String> rows) {
  final b = emptyBoard();
  const map = {
    '.': null,
    'K': TileKind.knutt,
    'M': TileKind.muschel,
  };
  for (var r = 0; r < 6; r++) {
    final row = rows[r];
    for (var c = 0; c < 6; c++) {
      b[r][c] = map[row[c]] ?? null;
    }
  }
  return b;
}

void main() {
  group('applyMove – Knutt', () {
    test('frisst Herzmuschel und setzt zweites Knutt auf Nachbarfeld', () {
      final rng = createMulberry32(42);
      final state = createInitialState(rng);
      final board = boardFromStrings([
        '......',
        '......',
        '..M...',
        '......',
        '......',
        '......',
      ]);
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.knutt,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final res = applyMove(s0, 3, 3, rng);
      expect(res.state.board[2][2], TileKind.knutt);
      expect(countTiles(res.state.board, TileKind.knutt), greaterThanOrEqualTo(2));
    });

    test('entfernt Knutt auf besetztem Zielfeld (Verhungern)', () {
      final rng = createMulberry32(1);
      final board = boardFromStrings([
        '......',
        '......',
        '..K...',
        '......',
        '......',
        '......',
      ]);
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.knutt,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final res = applyMove(s0, 3, 3, rng);
      expect(res.state.board[2][2], isNull);
    });

    test('entfernt zufälligen Knutt bei leerem Ziel', () {
      final rng = createMulberry32(99);
      final board = boardFromStrings([
        'K.K...',
        '......',
        '......',
        '......',
        '......',
        '......',
      ]);
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.knutt,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final before = countTiles(s0.board, TileKind.knutt);
      final res = applyMove(s0, 3, 3, rng);
      expect(countTiles(res.state.board, TileKind.knutt), before - 1);
    });
  });

  group('applyMove – Herzmuschel', () {
    test('setzt Muschel auf leeres Ziel', () {
      final rng = createMulberry32(7);
      final board = emptyBoard();
      board[2][2] = TileKind.muschel;
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.muschel,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final res = applyMove(s0, 1, 1, rng);
      expect(res.state.board[0][0], TileKind.muschel);
    });

    test('vermehrt auf Nachbarfeld wenn Ziel schon Muschel', () {
      final rng = createMulberry32(123);
      final board = boardFromStrings([
        '......',
        '......',
        '..M...',
        '......',
        '......',
        '......',
      ]);
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.muschel,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final before = countTiles(s0.board, TileKind.muschel);
      final res = applyMove(s0, 3, 3, rng);
      expect(countTiles(res.state.board, TileKind.muschel), before + 1);
    });

    test('bei Knutt: Ziel leer, neues Knutt auf Nachbarfeld', () {
      final rng = createMulberry32(555);
      final board = boardFromStrings([
        '......',
        '......',
        '..K...',
        '......',
        '......',
        '......',
      ]);
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.muschel,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final res = applyMove(s0, 3, 3, rng);
      expect(res.state.board[2][2], isNull);
      expect(countTiles(res.state.board, TileKind.knutt), 1);
    });
  });

  group('Einwanderung', () {
    test('platziert Knutt wenn Population 0', () {
      final rng = createMulberry32(11);
      final board = emptyBoard();
      board[0][0] = TileKind.muschel;
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.knutt,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final res = applyMove(s0, 2, 1, rng);
      expect(countTiles(res.state.board, TileKind.knutt), greaterThan(0));
    });
  });

  group('volles Spielfeld & Snapshots', () {
    test('setzt Pause-Zähler beim Übergang zu vollem Brett', () {
      final rng = createMulberry32(2024);
      final board = boardFromStrings([
        'MMMMMM',
        'MMMMMM',
        'MMMMMM',
        'MM.MMM',
        'MMMMMM',
        'MMMMMM',
      ]);
      final s0 = GameState(
        board: board,
        round: 0,
        currentPlayer: TileKind.muschel,
        musselSkipRounds: 0,
        history: [],
        snapshots: [],
        gameOver: false,
      );
      final res = applyMove(s0, 4, 4, rng);
      expect(isBoardFull(res.state.board), isTrue);
      expect(res.state.musselSkipRounds, 5);
    });

    test('nimmt Snapshot alle 10 Runden', () {
      final rng = createMulberry32(1);
      var s = createInitialState(rng);
      for (var i = 0; i < 10; i++) {
        final dx = rollDie(rng);
        final dy = rollDie(rng);
        s = applyMove(s, dx, dy, rng).state;
      }
      expect(s.snapshots.length, 1);
      expect(s.snapshots.first.round, 10);
    });
  });

  group('Spielende', () {
    test('endet nach 20 Snapshots', () {
      final rng = createMulberry32(77);
      var s = createInitialState(rng);
      var guard = 0;
      while (!s.gameOver && guard++ < 500) {
        s = applyMove(s, rollDie(rng), rollDie(rng), rng).state;
      }
      expect(s.gameOver, isTrue);
      expect(s.snapshots.length, 20);
    });
  });
}
