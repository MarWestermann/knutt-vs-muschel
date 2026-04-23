import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../engine/types.dart';

class PopulationChart extends StatelessWidget {
  const PopulationChart({
    super.key,
    required this.snapshots,
    this.compact = false,
    this.title = 'Population (alle 10 Runden)',
  });

  final List<PopulationSnapshot> snapshots;
  final bool compact;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nach 10 Würfen erscheint hier das Diagramm.'),
        ),
      );
    }

    final kn = snapshots.map((s) => s.knutt.toDouble()).toList();
    final ms = snapshots.map((s) => s.muschel.toDouble()).toList();
    final maxY = [
      ...kn,
      ...ms,
    ].reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: (maxY + 2).clamp(6, 40),
        titlesData: FlTitlesData(
          show: !compact,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, m) {
                final i = v.round();
                if (i < 0 || i >= snapshots.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${snapshots[i].round}',
                    style: TextStyle(fontSize: compact ? 8 : 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: compact ? 22 : 28,
              interval: 1,
              getTitlesWidget: (v, m) => Text(
                v.toInt().toString(),
                style: TextStyle(fontSize: compact ? 8 : 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: !compact, drawVerticalLine: false),
        borderData: FlBorderData(show: !compact),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              snapshots.length,
              (i) => FlSpot(i.toDouble(), kn[i]),
            ),
            isCurved: true,
            color: const Color(0xFFB83232),
            barWidth: compact ? 2 : 3,
            dotData: FlDotData(show: !compact),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0x1FB83232),
            ),
          ),
          LineChartBarData(
            spots: List.generate(
              snapshots.length,
              (i) => FlSpot(i.toDouble(), ms[i]),
            ),
            isCurved: true,
            color: const Color(0xFFC9A227),
            barWidth: compact ? 2 : 3,
            dotData: FlDotData(show: !compact),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0x1FC9A227),
            ),
          ),
        ],
      ),
    );
  }
}
