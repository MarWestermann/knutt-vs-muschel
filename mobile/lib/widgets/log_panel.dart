import 'package:flutter/material.dart';

import '../engine/types.dart';

class LogPanel extends StatelessWidget {
  const LogPanel({super.key, required this.entries});

  final List<RoundLog> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('Noch keine Würfe.'));
    }
    final rev = entries.reversed.toList();
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: rev.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final e = rev[i];
        final who = e.player == TileKind.knutt ? 'Knutt' : 'Herzmuschel';
        return ListTile(
          dense: true,
          title: Text('Runde ${e.round} · $who', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            'Wurf (${e.diceX}|${e.diceY})\n${e.result}',
            style: const TextStyle(height: 1.25),
          ),
        );
      },
    );
  }
}
