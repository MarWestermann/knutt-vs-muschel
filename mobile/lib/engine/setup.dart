import 'types.dart';
import 'rng.dart';

const int boardSize = 6;

Board emptyBoard() => List.generate(
      boardSize,
      (_) => List<Cell>.filled(boardSize, null, growable: false),
      growable: false,
    );

Board cloneBoard(Board board) =>
    board.map((row) => List<Cell>.from(row)).toList();

GameState cloneGameState(GameState state) => GameState(
      board: cloneBoard(state.board),
      round: state.round,
      currentPlayer: state.currentPlayer,
      musselSkipRounds: state.musselSkipRounds,
      history: List<RoundLog>.from(state.history),
      snapshots: List<PopulationSnapshot>.from(state.snapshots),
      gameOver: state.gameOver,
      gameOverReason: state.gameOverReason,
    );

void shuffleInPlace<T>(List<T> arr, Rng rng) {
  for (var i = arr.length - 1; i > 0; i--) {
    final j = (rng() * (i + 1)).floor();
    final tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
  }
}

int pickIndex(int n, Rng rng) {
  if (n <= 0) throw ArgumentError('pickIndex: n must be positive');
  return (rng() * n).floor();
}

GameState createInitialState(
  Rng rng, {
  TileKind starter = TileKind.knutt,
}) {
  final board = emptyBoard();
  final indices = List<int>.generate(boardSize * boardSize, (i) => i);
  shuffleInPlace(indices, rng);

  final muschelCells = indices.sublist(0, 10);
  final knuttCells = indices.sublist(10, 15);

  for (final i in muschelCells) {
    final r = i ~/ boardSize;
    final c = i % boardSize;
    board[r][c] = TileKind.muschel;
  }
  for (final i in knuttCells) {
    final r = i ~/ boardSize;
    final c = i % boardSize;
    board[r][c] = TileKind.knutt;
  }

  return GameState(
    board: board,
    round: 0,
    currentPlayer: starter,
    musselSkipRounds: 0,
    history: [],
    snapshots: [],
    gameOver: false,
  );
}
