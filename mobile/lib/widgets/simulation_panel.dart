import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/simulation_notifier.dart';
import 'population_chart.dart';

class SimulationPanel extends ConsumerStatefulWidget {
  const SimulationPanel({super.key});

  @override
  ConsumerState<SimulationPanel> createState() => _SimulationPanelState();
}

class _SimulationPanelState extends ConsumerState<SimulationPanel> {
  final _controller = TextEditingController(text: '4');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _parseCount() {
    final v = int.tryParse(_controller.text.trim());
    if (v == null) return 4;
    return v < 1 ? 1 : (v > 50 ? 50 : v);
  }

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Simulation',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Komplette Spiele automatisch bis zum Ende (200 Würfe oder 20 Protokollpunkte).',
            style: TextStyle(fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Anzahl Spiele',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    enabled: !sim.running,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: sim.running
                      ? null
                      : () => ref.read(simulationProvider.notifier).runSimulations(_parseCount()),
                  child: Text(sim.running ? 'Läuft… ${sim.current}/${sim.total}' : 'Simulieren'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: sim.running || sim.runs.isEmpty
                      ? null
                      : () => ref.read(simulationProvider.notifier).clear(),
                  child: const Text('Leeren'),
                ),
              ],
            ),
          ),
          if (sim.running) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: sim.total == 0 ? null : sim.current / sim.total),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: sim.runs.isEmpty
                ? const Center(child: Text('Noch keine Simulation gestartet.'))
                : LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth > 720 ? 2 : 1;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          childAspectRatio: cols == 2 ? 1.45 : 1.25,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: sim.runs.length,
                        itemBuilder: (context, i) {
                          final run = sim.runs[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Spiel ${run.id}',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${run.rounds} Würfe · Ende: Knutt ${run.finalKnutt} / Muschel ${run.finalMuschel}',
                                    style: TextStyle(fontSize: 11, color: Colors.brown.shade700),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: PopulationChart(
                                      snapshots: run.snapshots,
                                      compact: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
