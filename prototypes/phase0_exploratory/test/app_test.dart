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
  testWidgets(
    'offline completion renders persisted history and concept preview cannot change XP',
    (tester) async {
      final store = MemoryProgressStore();
      await tester.pumpWidget(ProjectIrlPrototypeApp(progressStore: store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One-task focus'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Start offline timer'));
      await tester.tap(find.text('Start offline timer'));
      await tester.pump();
      await tester.tap(find.text('I’m ready to finish'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes — I’m reporting that I did it'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Skip reflection'));
      await tester.tap(find.text('Skip reflection'));
      await tester.pumpAndSettle();
      expect(find.textContaining('+10 XP'), findsOneWidget);
      await tester.ensureVisible(find.text('See local progress'));
      await tester.tap(find.text('See local progress'));
      await tester.pumpAndSettle();
      expect(find.text('10 XP'), findsOneWidget);
      expect(find.textContaining('COMPLETED · SELF_REPORTED'), findsOneWidget);
      final before = store.data.totalXp;
      await tester.ensureVisible(find.text('Finish for now'));
      await tester.tap(find.text('Finish for now'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explore concepts (research only)'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Purchases and redemption are unavailable'),
        findsOneWidget,
      );
      await tester.tap(find.text('This optional content interests me'));
      await tester.pumpAndSettle();
      expect(store.data.totalXp, before);
      expect(
        store.data.researchSelections,
        contains('subscription-optional-content'),
      );
    },
  );
}
