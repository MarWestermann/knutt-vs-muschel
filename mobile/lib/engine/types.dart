/// Jäger
enum TileKind { knutt, muschel }

typedef Cell = TileKind?;

/// 6×6: board[row][col], row 0 = oben (Würfel y=1), col 0 = links (Würfel x=1)
typedef Board = List<List<Cell>>;

class RoundLog {
  const RoundLog({
    required this.round,
    required this.player,
    required this.diceX,
    required this.diceY,
    required this.result,
  });

  final int round;
  final TileKind player;
  final int diceX;
  final int diceY;
  final String result;
}

class PopulationSnapshot {
  const PopulationSnapshot({
    required this.round,
    required this.knutt,
    required this.muschel,
  });

  final int round;
  final int knutt;
  final int muschel;
}

class GameState {
  const GameState({
    required this.board,
    required this.round,
    required this.currentPlayer,
    required this.musselSkipRounds,
    required this.history,
    required this.snapshots,
    required this.gameOver,
    this.gameOverReason,
  });

  final Board board;
  final int round;
  final TileKind currentPlayer;
  final int musselSkipRounds;
  final List<RoundLog> history;
  final List<PopulationSnapshot> snapshots;
  final bool gameOver;
  final String? gameOverReason;
}

class SimulationRun {
  const SimulationRun({
    required this.id,
    required this.seed,
    required this.snapshots,
    required this.rounds,
    required this.finalKnutt,
    required this.finalMuschel,
  });

  final int id;
  final int seed;
  final List<PopulationSnapshot> snapshots;
  final int rounds;
  final int finalKnutt;
  final int finalMuschel;
}
