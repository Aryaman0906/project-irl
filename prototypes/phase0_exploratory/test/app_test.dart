import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_irl_phase0/src/app.dart';
import 'package:project_irl_phase0/src/progress_store.dart';

void main() {
  testWidgets('user can reach an offline quest session and cancel', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProjectIrlPrototypeApp(progressStore: MemoryProgressStore()),
    );
    await tester.pumpAndSettle();

    expect(find.text('A short step into real life'), findsOneWidget);
    await tester.tap(find.text('Choose a goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Focus'));
    await tester.pumpAndSettle();

    expect(find.text('Choose one quest'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(3));
    await tester.tap(find.text('One-task focus'));
    await tester.pumpAndSettle();
    expect(find.textContaining('timer only measures time'), findsOneWidget);

    await tester.ensureVisible(find.text('Start offline timer'));
    await tester.tap(find.text('Start offline timer'));
    await tester.pump();
    expect(find.text('Quest in progress'), findsOneWidget);
    await tester.tap(find.text('Cancel quest'));
    await tester.pumpAndSettle();
    expect(find.text('Choose one quest'), findsOneWidget);
  });
}
