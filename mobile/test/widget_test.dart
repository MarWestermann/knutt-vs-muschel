import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knutt_vs_muschel/app.dart';

void main() {
  testWidgets('App startet und zeigt Spielfeld-Titel', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KnuttApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Knutt vs. Herzmuschel'), findsWidgets);
    expect(find.text('Spielfeld'), findsOneWidget);
  });
}
