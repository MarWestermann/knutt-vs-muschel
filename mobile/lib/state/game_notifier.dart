import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/rules.dart';
import '../engine/rng.dart';
import '../engine/setup.dart';
import '../engine/types.dart';

class GameUiState {
  const GameUiState({
    required this.game,
    required this.seed,
    required this.rollSeq,
    this.lastDice,
    required this.rolling,
  });

  final GameState game;
  final int seed;
  final int rollSeq;
  final ({int x, int y})? lastDice;
  final bool rolling;

  GameUiState copyWith({
    GameState? game,
    int? seed,
    int? rollSeq,
    ({int x, int y})? lastDice,
    bool clearLastDice = false,
    bool? rolling,
  }) {
    return GameUiState(
      game: game ?? this.game,
      seed: seed ?? this.seed,
      rollSeq: rollSeq ?? this.rollSeq,
      lastDice: clearLastDice ? null : (lastDice ?? this.lastDice),
      rolling: rolling ?? this.rolling,
    );
  }
}

class GameNotifier extends StateNotifier<GameUiState> {
  GameNotifier() : super(_bootstrap());

  static GameUiState _bootstrap() {
    final seed = Random().nextInt(0x7fffffff);
    final r = createMulberry32(seed);
    final game = createInitialState(r);
    return GameUiState(
      game: game,
      seed: seed,
      rollSeq: 0,
      lastDice: null,
      rolling: false,
    );
  }

  void newGame() {
    final seed = Random().nextInt(0x7fffffff);
    final r = createMulberry32(seed);
    state = GameUiState(
      game: createInitialState(r),
      seed: seed,
      rollSeq: 0,
      lastDice: null,
      rolling: false,
    );
  }

  Future<void> rollDice() async {
    if (state.game.gameOver || state.rolling) return;
    final nextSeq = state.rollSeq + 1;
    final r = createMulberry32(mix32(state.seed, nextSeq));
    final dx = rollDie(r);
    final dy = rollDie(r);
    state = state.copyWith(
      rollSeq: nextSeq,
      lastDice: (x: dx, y: dy),
      rolling: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final next = applyMove(state.game, dx, dy, r).state;
    state = state.copyWith(game: next, rolling: false);
  }
}

final gameProvider =
    StateNotifierProvider<GameNotifier, GameUiState>((ref) => GameNotifier());
