import 'package:flutter/material.dart';

import '../engine/types.dart';

class CellWidget extends StatelessWidget {
  const CellWidget({super.key, required this.cell});

  final Cell cell;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (cell == TileKind.knutt) {
      child = Image.asset('assets/knutt.png', fit: BoxFit.contain);
    } else if (cell == TileKind.muschel) {
      child = Image.asset('assets/muschel.png', fit: BoxFit.contain);
    } else {
      child = const SizedBox.shrink();
    }

    return AnimatedScale(
      scale: cell == null ? 0.98 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }
}
