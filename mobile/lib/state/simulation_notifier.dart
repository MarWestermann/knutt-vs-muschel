import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/rng.dart';
import '../engine/rules.dart';
import '../engine/simulator.dart';
import '../engine/types.dart';

class SimulationUiState {
  const SimulationUiState({
    required this.running,
    required this.current,
    required this.total,
    required this.runs,
  });

  final bool running;
  final int current;
  final int total;
  final List<SimulationRun> runs;

  SimulationUiState copyWith({
    bool? running,
    int? current,
    int? total,
    List<SimulationRun>? runs,
  }) {
    return SimulationUiState(
      running: running ?? this.running,
      current: current ?? this.current,
      total: total ?? this.total,
      runs: runs ?? this.runs,
    );
  }
}

class SimulationNotifier extends StateNotifier<SimulationUiState> {
  SimulationNotifier()
      : super(
          const SimulationUiState(
            running: false,
            current: 0,
            total: 0,
            runs: [],
          ),
        );

  Future<void> runSimulations(int count) async {
    if (state.running) return;
    final n = count < 1 ? 1 : (count > 50 ? 50 : count);
    state = SimulationUiState(
      running: true,
      current: 0,
      total: n,
      runs: [],
    );
    final baseSeed = Random().nextInt(0x7fffffff);
    final runs = <SimulationRun>[];
    for (var i = 0; i < n; i++) {
      final seed = mix32(baseSeed, i + 1);
      final finalState = simulateFullGame(seed);
      runs.add(
        SimulationRun(
          id: i + 1,
          seed: seed,
          snapshots: List<PopulationSnapshot>.from(finalState.snapshots),
          rounds: finalState.round,
          finalKnutt: countTiles(finalState.board, TileKind.knutt),
          finalMuschel: countTiles(finalState.board, TileKind.muschel),
        ),
      );
      state = SimulationUiState(
        running: true,
        current: i + 1,
        total: n,
        runs: List<SimulationRun>.from(runs),
      );
      await Future<void>.delayed(Duration.zero);
    }
    state = SimulationUiState(
      running: false,
      current: n,
      total: n,
      runs: runs,
    );
  }

  void clear() {
    state = const SimulationUiState(
      running: false,
      current: 0,
      total: 0,
      runs: [],
    );
  }
}

final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationUiState>(
  (ref) => SimulationNotifier(),
);
