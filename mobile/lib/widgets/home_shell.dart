import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/types.dart';
import '../state/game_notifier.dart';
import 'board_widget.dart';
import 'dice_widget.dart';
import 'log_panel.dart';
import 'player_panel.dart';
import 'population_chart.dart';
import 'rules_sheet.dart';
import 'simulation_panel.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Knutt vs. Herzmuschel'),
          actions: [
            TextButton(
              onPressed: () => RulesSheet.show(context),
              child: const Text('Regeln'),
            ),
            TextButton(
              onPressed: gameNotifier.newGame,
              child: const Text('Neues Spiel'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Spielen'),
              Tab(text: 'Diagramm'),
              Tab(text: 'Protokoll'),
              Tab(text: 'Simulation'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 12),
          child: TabBarView(
            children: [
              _PlayTab(
                game: g.game,
                lastDice: g.lastDice,
                rolling: g.rolling,
                onRoll: gameNotifier.rollDice,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Live-Diagramm',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: PopulationChart(snapshots: g.game.snapshots),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                child: LogPanel(entries: g.game.history),
              ),
              const SimulationPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayTab extends StatelessWidget {
  const _PlayTab({
    required this.game,
    required this.lastDice,
    required this.rolling,
    required this.onRoll,
  });

  final GameState game;
  final ({int x, int y})? lastDice;
  final bool rolling;
  final Future<void> Function() onRoll;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Gesten-Navigation / Systemleiste: viewPadding.bottom zuverlässiger als padding.bottom
    final bottomInset = mq.viewPadding.bottom + mq.padding.bottom;
    return LayoutBuilder(
      builder: (context, c) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 10 + bottomInset + 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight - 20),
            child: Column(
              children: [
                PlayerPanel(
                  board: game.board,
                  current: game.currentPlayer,
                  gameOver: game.gameOver,
                  skipRounds: game.musselSkipRounds,
                ),
                const SizedBox(height: 10),
                BoardWidget(
                  board: game.board,
                  highlight: lastDice,
                ),
                const SizedBox(height: 8),
                Text(
                  'Wurf ${game.round} / 200 · Protokollpunkte: ${game.snapshots.length} / 20',
                  style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.w600),
                ),
                if (game.gameOver)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Ende. ${game.gameOverReason ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 8),
                DiceWidget(
                  x: lastDice?.x,
                  y: lastDice?.y,
                  rolling: rolling,
                  enabled: !game.gameOver,
                  onRoll: onRoll,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
