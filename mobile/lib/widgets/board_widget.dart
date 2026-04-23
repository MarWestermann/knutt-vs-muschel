import 'package:flutter/material.dart';

import '../engine/types.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.board,
    this.highlight,
  });

  final Board board;
  final ({int x, int y})? highlight;

  static const _headerX = Color(0xFFEC3F8A);
  static const _headerY = Color(0xFFFFD400);
  static const _cellBg = Color(0xFF1A8C8A);
  static const _cellActive = Color(0xFF25B5B3);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4E4C1),
              Color(0xFFE7D2A3),
              Color(0xFFD8BF86),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              offset: Offset(0, 8),
              color: Color(0x26000000),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 6, bottom: 6),
              child: Text(
                'Spielfeld',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Color(0xFF5A3A1F),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final gap = (c.maxWidth * 0.012).clamp(3.0, 6.0);
                  return Column(
                    children: List.generate(7, (ri) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: ri < 6 ? gap : 0),
                          child: Row(
                            children: List.generate(7, (ci) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: ci < 6 ? gap : 0),
                                  child: _cellFor(ri, ci),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Im Wattenmeer treffen Knutt und Herzmuschel u. a. aufeinander. '
              'In der Realität kommen weitere Faktoren dazu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                fontSize: 12,
                height: 1.3,
                color: Color(0xFF5A3A1F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cellFor(int ri, int ci) {
    if (ri == 0 && ci == 0) {
      return const SizedBox.shrink();
    }
    if (ri == 0) {
      return _pill(text: '$ci', bg: _headerX, fg: Colors.white);
    }
    if (ci == 0) {
      return _pill(text: '$ri', bg: _headerY, fg: Colors.black87);
    }
    final x = ci;
    final y = ri;
    final cell = board[y - 1][x - 1];
    final isActive = highlight != null && highlight!.x == x && highlight!.y == y;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isActive ? _cellActive : _cellBg,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(child: CellWidget(cell: cell)),
    );
  }

  Widget _pill({required String text, required Color bg, required Color fg}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: fg,
          ),
        ),
      ),
    );
  }
}
