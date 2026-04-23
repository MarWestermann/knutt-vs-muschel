import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knutt_vs_muschel/engine/rng.dart';
import 'package:knutt_vs_muschel/engine/rules.dart';
import 'package:knutt_vs_muschel/engine/setup.dart';
import 'package:knutt_vs_muschel/engine/types.dart';
import 'package:knutt_vs_muschel/widgets/board_widget.dart';

void main() {
  testWidgets('Startaufstellung: 10 Muscheln + 5 Knutts', (tester) async {
    final rng = createMulberry32(12345);
    final game = createInitialState(rng);
    expect(countTiles(game.board, TileKind.muschel), 10);
    expect(countTiles(game.board, TileKind.knutt), 5);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 500,
              child: BoardWidget(board: game.board),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNWidgets(15));
  });
}
