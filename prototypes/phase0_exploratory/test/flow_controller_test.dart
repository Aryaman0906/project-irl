import 'package:flutter_test/flutter_test.dart';
import 'package:project_irl_phase0/src/flow_controller.dart';
import 'package:project_irl_phase0/src/models.dart';
import 'package:project_irl_phase0/src/progress_service.dart';
import 'package:project_irl_phase0/src/progress_store.dart';
import 'package:project_irl_phase0/src/quest_catalog.dart';

void main() {
  late DateTime now;
  late MemoryProgressStore store;
  late ProgressService service;
  setUp(() {
    now = DateTime(2026, 10, 3, 10);
    store = MemoryProgressStore();
    service = ProgressService(store, clock: () => now);
  });

  test('atomic completion persists attempt and exactly one award', () async {
    await service.initialize();
    final attempt = await service.start(questCatalog.first);
    now = now.add(const Duration(minutes: 20));
    final first = await service.complete(
      attempt.id,
      const ReflectionAnswer(
        difficulty: 'Manageable',
        helpedMost: 'Clear task',
      ),
    );
    final repeated = await service.complete(
      attempt.id,
      const ReflectionAnswer(difficulty: 'Easy', helpedMost: 'Quiet'),
    );
    expect(first.award?.amount, RewardPolicy.completionXp);
    expect(repeated.award?.id, first.award?.id);
    expect(store.data.attempts.single.status, AttemptStatus.completed);
    expect(store.data.awards, hasLength(1));
  });

  test('save failure leaves completion and award both unapplied', () async {
    await service.initialize();
    final attempt = await service.start(questCatalog.first);
    store.failNextSave = true;
    await expectLater(
      service.complete(
        attempt.id,
        const ReflectionAnswer(difficulty: 'Skipped', helpedMost: 'Skipped'),
      ),
      throwsA(isA<ProgressStoreException>()),
    );
    expect(store.data.attempts.single.status, AttemptStatus.active);
    expect(store.data.awards, isEmpty);
  });

  test('restart converts active timing to explicit interruption', () async {
    await service.initialize();
    await service.start(questCatalog.first);
    final restarted = ProgressService(
      store,
      clock: () => now.add(const Duration(minutes: 2)),
    );
    await restarted.initialize();
    expect(restarted.activeAttempt?.status, AttemptStatus.interrupted);
    expect(restarted.activeAttempt?.timingNote, contains('stopped'));
  });

  test('cancel is retained and earns no XP', () async {
    await service.initialize();
    final attempt = await service.start(questCatalog.first);
    await service.cancel(attempt.id);
    expect(store.data.attempts.single.status, AttemptStatus.cancelled);
    expect(store.data.awards, isEmpty);
  });

  test('daily and per-quest limits use local calendar boundaries', () async {
    await service.initialize();
    for (var i = 0; i < 4; i++) {
      final attempt = await service.start(questCatalog[i % 3]);
      now = now.add(const Duration(minutes: 1));
      await service.complete(
        attempt.id,
        const ReflectionAnswer(difficulty: 'Skipped', helpedMost: 'Skipped'),
      );
    }
    expect(store.data.totalXp, 30);
    expect(store.data.awards, hasLength(3));
    now = DateTime(2026, 10, 4, 1);
    final nextDay = await service.start(questCatalog.first);
    final result = await service.complete(
      nextDay.id,
      const ReflectionAnswer(difficulty: 'Skipped', helpedMost: 'Skipped'),
    );
    expect(result.award?.amount, 10);
  });

  test('backward clock marks timing uncertain without granting XP', () async {
    await service.initialize();
    final attempt = await service.start(questCatalog.first);
    now = now.subtract(const Duration(hours: 1));
    await service.checkpoint(attempt.id);
    expect(service.activeAttempt?.status, AttemptStatus.interrupted);
    expect(store.data.awards, isEmpty);
  });

  test(
    'reset clears all persisted data and remains empty after reopen',
    () async {
      await service.initialize();
      await service.start(questCatalog.first);
      await service.selectConcept('toys');
      await service.reset();
      final reopened = ProgressService(store);
      await reopened.initialize();
      expect(reopened.data.attempts, isEmpty);
      expect(reopened.data.researchSelections, isEmpty);
    },
  );

  test('milestone thresholds include exact boundaries', () async {
    final awards = [
      for (var i = 0; i < 7; i++)
        XpAward(
          id: 'a$i',
          attemptId: 'x$i',
          amount: 10,
          reasonCode: 'TEST',
          policyVersion: 1,
          awardedAt: now,
        ),
    ];
    final controller = QuestFlowController(
      MemoryProgressStore(PrototypeData(awards: awards)),
      clock: () => now,
    );
    await controller.initialize();
    expect(controller.totalXp, 70);
    expect(controller.milestoneIndex, 2);
    expect(controller.nextMilestone, 120);
    controller.dispose();
  });
}
