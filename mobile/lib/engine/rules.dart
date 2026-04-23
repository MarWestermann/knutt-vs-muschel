import 'setup.dart';
import 'rng.dart';
import 'types.dart';

const int maxRounds = 200;
const int snapshotInterval = 10;
const int maxSnapshots = 20;

int countTiles(Board board, TileKind kind) {
  var n = 0;
  for (var r = 0; r < boardSize; r++) {
    for (var c = 0; c < boardSize; c++) {
      if (board[r][c] == kind) n++;
    }
  }
  return n;
}

bool isBoardFull(Board board) {
  for (var r = 0; r < boardSize; r++) {
    for (var c = 0; c < boardSize; c++) {
      if (board[r][c] == null) return false;
    }
  }
  return true;
}

List<(int, int)> neighbors8(int r, int c) {
  final out = <(int, int)>[];
  for (var dr = -1; dr <= 1; dr++) {
    for (var dc = -1; dc <= 1; dc++) {
      if (dr == 0 && dc == 0) continue;
      final nr = r + dr;
      final nc = c + dc;
      if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize) {
        out.add((nr, nc));
      }
    }
  }
  return out;
}

List<(int, int)> allCellsWith(Board board, TileKind kind) {
  final out = <(int, int)>[];
  for (var r = 0; r < boardSize; r++) {
    for (var c = 0; c < boardSize; c++) {
      if (board[r][c] == kind) out.add((r, c));
    }
  }
  return out;
}

List<(int, int)> allEmptyCells(Board board) {
  final out = <(int, int)>[];
  for (var r = 0; r < boardSize; r++) {
    for (var c = 0; c < boardSize; c++) {
      if (board[r][c] == null) out.add((r, c));
    }
  }
  return out;
}

(int, int) pickRandomCell(List<(int, int)> cells, Rng rng) =>
    cells[pickIndex(cells.length, rng)];

List<(int, int)> freeNeighbors(Board board, int r, int c) =>
    neighbors8(r, c).where((p) => board[p.$1][p.$2] == null).toList();

List<String> applyImmigration(Board board, Rng rng) {
  final msgs = <String>[];
  List<(int, int)> empty() => allEmptyCells(board);

  if (countTiles(board, TileKind.knutt) == 0) {
    final e = empty();
    if (e.isNotEmpty) {
      final p = pickRandomCell(e, rng);
      board[p.$1][p.$2] = TileKind.knutt;
      msgs.add('Einwanderung: Ein Knutt erscheint auf dem Spielfeld.');
    }
  }
  if (countTiles(board, TileKind.muschel) == 0) {
    final e = empty();
    if (e.isNotEmpty) {
      final p = pickRandomCell(e, rng);
      board[p.$1][p.$2] = TileKind.muschel;
      msgs.add('Einwanderung: Eine Herzmuschel erscheint auf dem Spielfeld.');
    }
  }
  return msgs;
}

class ApplyMoveResult {
  const ApplyMoveResult({required this.state, required this.messages});

  final GameState state;
  final List<String> messages;
}

ApplyMoveResult applyMove(
  GameState state,
  int diceX,
  int diceY,
  Rng rng,
) {
  if (state.gameOver) {
    return ApplyMoveResult(
      state: cloneGameState(state),
      messages: ['Spiel ist bereits beendet.'],
    );
  }

  final board = cloneBoard(state.board);
  var musselSkipRounds = state.musselSkipRounds;
  final fullBefore = isBoardFull(board);
  final player = state.currentPlayer;
  final row = diceY - 1;
  final col = diceX - 1;
  final cell = board[row][col];

  final messages = <String>[];
  final coord = 'Feld ($diceX|$diceY)';

  if (player == TileKind.knutt) {
    if (cell == TileKind.muschel) {
      board[row][col] = TileKind.knutt;
      final free = freeNeighbors(board, row, col);
      if (free.isNotEmpty) {
        final p = pickRandomCell(free, rng);
        board[p.$1][p.$2] = TileKind.knutt;
        messages.add(
          '$coord: Knutt frisst Herzmuschel und vermehrt sich (zweites Knutt auf Nachbarfeld).',
        );
      } else {
        messages.add(
          '$coord: Knutt frisst Herzmuschel (kein freies Nachbarfeld für Vermehrung).',
        );
      }
    } else if (cell == TileKind.knutt) {
      board[row][col] = null;
      messages.add('$coord: Knutt verhungert (Ziel war besetzt).');
    } else {
      final knutts = allCellsWith(board, TileKind.knutt);
      if (knutts.isEmpty) {
        messages.add('$coord: Leeres Ziel – keine Knutts zum Entfernen.');
      } else {
        final p = pickRandomCell(knutts, rng);
        board[p.$1][p.$2] = null;
        messages.add(
          '$coord: Knutt verhungert – ein Knutt wird vom Spielfeld entfernt.',
        );
      }
    }
  } else {
    if (cell == TileKind.knutt) {
      board[row][col] = null;
      final free = freeNeighbors(board, row, col);
      if (free.isNotEmpty) {
        final p = pickRandomCell(free, rng);
        board[p.$1][p.$2] = TileKind.knutt;
        messages.add('$coord: Herzmuschel wird gefressen – Knutt auf Nachbarfeld.');
      } else {
        board[row][col] = TileKind.knutt;
        messages.add(
          '$coord: Herzmuschel wird gefressen – kein Nachbarfeld frei, Knutt bleibt am Ziel.',
        );
      }
    } else {
      final full = isBoardFull(board);
      if (full && musselSkipRounds > 0) {
        musselSkipRounds -= 1;
        messages.add(
          '$coord: Herzmuschel-Vermehrung ausgesetzt (volles Spielfeld, noch $musselSkipRounds Pause-Züge).',
        );
      } else if (cell == null) {
        board[row][col] = TileKind.muschel;
        messages.add(
          '$coord: Herzmuschel vermehrt sich (neues Plättchen auf leeres Ziel).',
        );
      } else {
        final free = freeNeighbors(board, row, col);
        if (free.isNotEmpty) {
          final p = pickRandomCell(free, rng);
          board[p.$1][p.$2] = TileKind.muschel;
          messages.add('$coord: Herzmuschel vermehrt sich (Nachbarfeld).');
        } else {
          messages.add(
            '$coord: Herzmuschel kann sich nicht vermehren (kein freies Nachbarfeld).',
          );
        }
      }
    }
  }

  messages.addAll(applyImmigration(board, rng));

  final fullAfter = isBoardFull(board);
  if (!fullAfter) {
    musselSkipRounds = 0;
  } else if (!fullBefore && fullAfter) {
    musselSkipRounds = 5;
  }

  final newRound = state.round + 1;
  final summary = messages.join(' ');
  final history = List<RoundLog>.from(state.history)
    ..add(
      RoundLog(
        round: newRound,
        player: player,
        diceX: diceX,
        diceY: diceY,
        result: summary,
      ),
    );

  final snapshots = List<PopulationSnapshot>.from(state.snapshots);
  if (newRound % snapshotInterval == 0 && snapshots.length < maxSnapshots) {
    snapshots.add(
      PopulationSnapshot(
        round: newRound,
        knutt: countTiles(board, TileKind.knutt),
        muschel: countTiles(board, TileKind.muschel),
      ),
    );
  }

  final nextPlayer =
      player == TileKind.knutt ? TileKind.muschel : TileKind.knutt;

  var gameOver = false;
  String? gameOverReason;
  if (newRound >= maxRounds || snapshots.length >= maxSnapshots) {
    gameOver = true;
    gameOverReason = snapshots.length >= maxSnapshots
        ? '20 Protokollpunkte erreicht (wie im Original).'
        : '200 Würfe erreicht.';
  }

  final next = GameState(
    board: board,
    round: newRound,
    currentPlayer: nextPlayer,
    musselSkipRounds: musselSkipRounds,
    history: history,
    snapshots: snapshots,
    gameOver: gameOver,
    gameOverReason: gameOverReason,
  );

  return ApplyMoveResult(state: next, messages: messages);
}

int rollDie(Rng rng) => pickIndex(6, rng) + 1;
