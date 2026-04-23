import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiceWidget extends StatelessWidget {
  const DiceWidget({
    super.key,
    required this.x,
    required this.y,
    required this.rolling,
    required this.onRoll,
    required this.enabled,
  });

  final int? x;
  final int? y;
  final bool rolling;
  final Future<void> Function() onRoll;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _die(label: 'Spalte (x)', value: x, rolling: rolling),
            const SizedBox(width: 16),
            _die(label: 'Zeile (y)', value: y, rolling: rolling),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: enabled && !rolling
              ? () async {
                  HapticFeedback.lightImpact();
                  await onRoll();
                }
              : null,
          child: Text(rolling ? 'Würfelt…' : 'Würfeln'),
        ),
      ],
    );
  }

  Widget _die({required String label, required int? value, required bool rolling}) {
    final face = value == null ? '–' : '$value';
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 4),
        AnimatedRotation(
          turns: rolling ? 0.02 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF8F0), Color(0xFFE8DCC8)],
              ),
              boxShadow: const [
                BoxShadow(color: Color(0xFFB8A990), offset: Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                face,
                key: ValueKey(face),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
