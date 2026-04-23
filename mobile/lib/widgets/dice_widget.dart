import 'dart:math';
import 'dart:ui' show lerpDouble;

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
            Column(
              children: [
                const Text(
                  'Spalte (x)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                _Die(value: x, rolling: rolling, tint: _DieTint.x),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                const Text(
                  'Zeile (y)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                _Die(value: y, rolling: rolling, tint: _DieTint.y),
              ],
            ),
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
}

enum _DieTint { x, y }

extension _DieTintColors on _DieTint {
  List<Color> get faceGradient {
    switch (this) {
      case _DieTint.x:
        return const [Color(0xFFFFF5EC), Color(0xFFF3DCC2), Color(0xFFD6B48A)];
      case _DieTint.y:
        return const [Color(0xFFF4F9F5), Color(0xFFD8EBD8), Color(0xFFA9C8B0)];
    }
  }

  List<Color> get pipGradient {
    switch (this) {
      case _DieTint.x:
        return const [Color(0xFF6B2A1A), Color(0xFF170504)];
      case _DieTint.y:
        return const [Color(0xFF1F4A2A), Color(0xFF051208)];
    }
  }
}

/// Pip-Positionen je Augenzahl auf einem 3x3-Raster (1..9, von oben-links).
List<int> _pipPositions(int pips) {
  switch (pips) {
    case 1:
      return const [5];
    case 2:
      return const [1, 9];
    case 3:
      return const [1, 5, 9];
    case 4:
      return const [1, 3, 7, 9];
    case 5:
      return const [1, 3, 5, 7, 9];
    case 6:
      return const [1, 3, 4, 6, 7, 9];
    default:
      return const [];
  }
}

class _Die extends StatefulWidget {
  const _Die({
    required this.value,
    required this.rolling,
    required this.tint,
  });

  final int? value;
  final bool rolling;
  final _DieTint tint;

  @override
  State<_Die> createState() => _DieState();
}

class _DieState extends State<_Die> with SingleTickerProviderStateMixin {
  static const double _size = 64;
  static const double _hopHeight = 22;
  static const Duration _spinPeriod = Duration(milliseconds: 600);
  static const Duration _settleDuration = Duration(milliseconds: 280);

  late final AnimationController _ctrl;
  final Random _rng = Random();

  // Tumble-Parameter (Gesamt-Rotation pro Periode in Radiant).
  double _rxTotal = 4 * pi;
  double _ryTotal = 6 * pi;
  double _rzTotal = 2 * pi;

  // Beim Übergang in die Endlage: Startwinkel des Settle-Tweens.
  double _settleStartRx = 0;
  double _settleStartRy = 0;
  double _settleStartRz = 0;
  bool _settling = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _spinPeriod);
    if (widget.rolling) {
      _startTumble();
    }
  }

  @override
  void didUpdateWidget(covariant _Die old) {
    super.didUpdateWidget(old);
    if (widget.rolling && !old.rolling) {
      _startTumble();
    } else if (!widget.rolling && old.rolling) {
      _startSettle();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _randomizeTumble() {
    int sign() => _rng.nextBool() ? 1 : -1;
    double spin() => (2 + _rng.nextInt(3)) * 2 * pi * sign();
    _rxTotal = spin();
    _ryTotal = spin();
    _rzTotal = spin() / 2;
  }

  void _startTumble() {
    _randomizeTumble();
    _settling = false;
    _ctrl
      ..duration = _spinPeriod
      ..repeat();
  }

  void _startSettle() {
    final t = _ctrl.value;
    _settleStartRx = _rxTotal * t;
    _settleStartRy = _ryTotal * t;
    _settleStartRz = _rzTotal * t;
    _ctrl.stop();
    setState(() => _settling = true);
    _ctrl
      ..duration = _settleDuration
      ..forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _settling = false);
      });
  }

  ({double rx, double ry, double rz}) _faceAngles(int? n) {
    switch (n) {
      case 1:
        return (rx: 0, ry: 0, rz: 0);
      case 2:
        return (rx: 0, ry: -pi / 2, rz: 0);
      case 3:
        return (rx: -pi / 2, ry: 0, rz: 0);
      case 4:
        return (rx: pi / 2, ry: 0, rz: 0);
      case 5:
        return (rx: 0, ry: pi / 2, rz: 0);
      case 6:
        return (rx: 0, ry: pi, rz: 0);
      default:
        // Leichte 3/4-Ansicht, solange noch nicht gewürfelt wurde.
        return (rx: -0.35, ry: 0.45, rz: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size + 8,
      height: _size + _hopHeight + 12,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          double rx, ry, rz;
          double bounceY = 0;
          double shadowScale = 1;

          if (widget.rolling) {
            final t = _ctrl.value;
            rx = _rxTotal * t;
            ry = _ryTotal * t;
            rz = _rzTotal * t;
            // Ein Hopser pro Periode.
            final phase = t * pi;
            final hop = sin(phase);
            bounceY = -hop * _hopHeight;
            shadowScale = 1 - 0.5 * hop;
          } else if (_settling) {
            final t = Curves.easeOut.transform(_ctrl.value);
            final f = _faceAngles(widget.value);
            rx = lerpDouble(_settleStartRx, f.rx, t)!;
            ry = lerpDouble(_settleStartRy, f.ry, t)!;
            rz = lerpDouble(_settleStartRz, f.rz, t)!;
          } else {
            final f = _faceAngles(widget.value);
            rx = f.rx;
            ry = f.ry;
            rz = f.rz;
          }

          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 2,
                child: Transform.scale(
                  scaleX: shadowScale,
                  scaleY: shadowScale,
                  child: Container(
                    width: _size * 0.95,
                    height: 9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const RadialGradient(
                        colors: [Color(0x66000000), Color(0x00000000)],
                        stops: [0.0, 0.85],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8 - bounceY,
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: _Cube(
                    rx: rx,
                    ry: ry,
                    rz: rz,
                    size: _size,
                    tint: widget.tint,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Cube extends StatelessWidget {
  const _Cube({
    required this.rx,
    required this.ry,
    required this.rz,
    required this.size,
    required this.tint,
  });

  final double rx;
  final double ry;
  final double rz;
  final double size;
  final _DieTint tint;

  @override
  Widget build(BuildContext context) {
    final cubeMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0015)
      ..rotateX(rx)
      ..rotateY(ry)
      ..rotateZ(rz);
    final half = size / 2;

    Matrix4 faceMatrix(void Function(Matrix4) rotate) {
      final m = Matrix4.identity();
      rotate(m);
      m.multiply(Matrix4.translationValues(0.0, 0.0, half));
      return m;
    }

    return Transform(
      transform: cubeMatrix,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _faceLayer(1, faceMatrix((_) {})),
          _faceLayer(2, faceMatrix((m) => m.rotateY(pi / 2))),
          _faceLayer(3, faceMatrix((m) => m.rotateX(pi / 2))),
          _faceLayer(4, faceMatrix((m) => m.rotateX(-pi / 2))),
          _faceLayer(5, faceMatrix((m) => m.rotateY(-pi / 2))),
          _faceLayer(6, faceMatrix((m) => m.rotateY(pi))),
        ],
      ),
    );
  }

  Widget _faceLayer(int pips, Matrix4 transform) {
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: _Face(pips: pips, size: size, tint: tint),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({
    required this.pips,
    required this.size,
    required this.tint,
  });

  final int pips;
  final double size;
  final _DieTint tint;

  @override
  Widget build(BuildContext context) {
    final positions = _pipPositions(pips);
    final pad = size * 0.10;
    final gap = size * 0.03;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tint.faceGradient,
          stops: const [0.0, 0.6, 1.0],
        ),
        border: Border.all(
          color: const Color(0x59785F3C),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(pad),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        children: List.generate(9, (i) {
          final pos = i + 1;
          if (!positions.contains(pos)) return const SizedBox.shrink();
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 0.85,
                colors: tint.pipGradient,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
