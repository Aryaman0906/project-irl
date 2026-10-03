import 'models.dart';
import 'progress_store.dart';

typedef Clock = DateTime Function();

class RewardPolicy {
  static const version = 1;
  static const completionXp = 10;
  static const dailyXpLimit = 30;
  static const perQuestDailyXpLimit = 10;
  static const milestoneThresholds = [0, 30, 70, 120, 200];
}

class CompletionResult {
  const CompletionResult(this.attempt, this.award, this.explanation);
  final QuestAttempt attempt;
  final XpAward? award;
  final String explanation;
}

class ProgressService {
  ProgressService(this.store, {Clock? clock}) : clock = clock ?? DateTime.now;
  final ProgressStore store;
  final Clock clock;
  PrototypeData data = const PrototypeData();
  Future<void> initialize() async {
    data = await store.load();
    final changed = data.attempts
        .map(
          (a) => a.status == AttemptStatus.active
              ? a.copyWith(
                  status: AttemptStatus.interrupted,
                  timingNote: 'The app stopped while timing. Review and resume or cancel.',
                )
              : a,
        )
        .toList();
    if (changed.any((a) => a.status == AttemptStatus.interrupted) &&
        data.attempts.any((a) => a.status == AttemptStatus.active)) {
      data = PrototypeData(
        attempts: changed,
        awards: data.awards,
        researchSelections: data.researchSelections,
      );
      await store.save(data);
    }
  }

  QuestAttempt? get activeAttempt {
    for (final a in data.attempts.reversed) {
      if (a.status == AttemptStatus.active ||
          a.status == AttemptStatus.interrupted) {
        return a;
      }
    }
    return null;
  }

  Future<QuestAttempt> start(Quest quest) async {
    if (activeAttempt != null) {
      throw const ProgressStoreException(
        'Finish or cancel the current quest before starting another.',
      );
    }
    final now = clock();
    final attempt = QuestAttempt(
      id: 'attempt-${now.microsecondsSinceEpoch}-${quest.id}',
      questId: quest.id,
      questVersion: quest.version,
      startedAt: now,
      status: AttemptStatus.active,
      evidence: EvidenceLabel.selfReported,
    );
    await _commit(
      PrototypeData(
        attempts: [...data.attempts, attempt],
        awards: data.awards,
        researchSelections: data.researchSelections,
      ),
    );
    return attempt;
  }

  Future<void> checkpoint(String id) async {
    final now = clock();
    final attempts = data.attempts.map((a) {
      if (a.id != id || a.status != AttemptStatus.active) return a;
      final delta = now.difference(a.startedAt);
      if (delta.isNegative) {
        return a.copyWith(
          status: AttemptStatus.interrupted,
          timingNote: 'Device time moved backwards; timing is uncertain.',
        );
      }
      return a.copyWith(elapsedSeconds: delta.inSeconds);
    }).toList();
    await _commit(
      PrototypeData(
        attempts: attempts,
        awards: data.awards,
        researchSelections: data.researchSelections,
      ),
    );
  }

  Future<CompletionResult> complete(
    String id,
    ReflectionAnswer reflection,
  ) async {
    final existingAward = data.awards
        .where((e) => e.attemptId == id)
        .firstOrNull;
    final original = data.attempts.where((e) => e.id == id).firstOrNull;
    if (original == null) {
      throw const ProgressStoreException('This attempt was not found.');
    }
    if (original.status == AttemptStatus.completed) {
      return CompletionResult(
        original,
        existingAward,
        existingAward == null
            ? 'Recorded without XP.'
            : 'XP was already awarded once.',
      );
    }
    if (original.status == AttemptStatus.cancelled ||
        original.status == AttemptStatus.abandoned) {
      throw const ProgressStoreException(
        'A cancelled attempt cannot be completed.',
      );
    }
    final now = clock();
    final localDay = DateTime(now.year, now.month, now.day);
    final todayAwards = data.awards.where((a) {
      final d = a.awardedAt;
      return DateTime(d.year, d.month, d.day) == localDay;
    }).toList();
    final questAttempts = data.attempts
        .where((a) => a.questId == original.questId)
        .map((a) => a.id)
        .toSet();
    final questToday = todayAwards.fold(
      0,
      (sum, a) => sum + (questAttempts.contains(a.attemptId) ? a.amount : 0),
    );
    final daily = todayAwards.fold(0, (sum, a) => sum + a.amount);
    XpAward? award;
    var explanation =
        'Practice recorded, but the daily 30 XP limit was reached.';
    if (daily < RewardPolicy.dailyXpLimit &&
        questToday < RewardPolicy.perQuestDailyXpLimit &&
        existingAward == null) {
      final amount = RewardPolicy.completionXp.clamp(
        0,
        RewardPolicy.dailyXpLimit - daily,
      );
      award = XpAward(
        id: 'award-$id-v${RewardPolicy.version}',
        attemptId: id,
        amount: amount,
        reasonCode: 'SELF_REPORTED_PARTICIPATION',
        policyVersion: RewardPolicy.version,
        awardedAt: now,
      );
      explanation = '+$amount XP for self-reported participation (non-cash).';
    } else if (questToday >= RewardPolicy.perQuestDailyXpLimit) {
      explanation = 'Practice recorded, but this quest already earned its daily 10 XP limit.';
    }
    final elapsed = now.difference(original.startedAt);
    final completed = original.copyWith(
      status: AttemptStatus.completed,
      endedAt: now,
      elapsedSeconds: elapsed.isNegative
          ? original.elapsedSeconds
          : elapsed.inSeconds,
      reflection: reflection,
      timingNote: elapsed.isNegative
          ? 'Device time moved backwards; elapsed timing is uncertain.'
          : original.timingNote,
    );
    final attempts = data.attempts
        .map((a) => a.id == id ? completed : a)
        .toList();
    await _commit(
      PrototypeData(
        attempts: attempts,
        awards: award == null ? data.awards : [...data.awards, award],
        researchSelections: data.researchSelections,
      ),
    );
    return CompletionResult(completed, award, explanation);
  }

  Future<void> cancel(String id) async {
    final now = clock();
    final attempts = data.attempts
        .map(
          (a) =>
              a.id == id &&
                  (a.status == AttemptStatus.active ||
                      a.status == AttemptStatus.interrupted)
              ? a.copyWith(status: AttemptStatus.cancelled, endedAt: now)
              : a,
        )
        .toList();
    await _commit(
      PrototypeData(
        attempts: attempts,
        awards: data.awards,
        researchSelections: data.researchSelections,
      ),
    );
  }

  Future<void> resume(String id) async {
    final attempts = data.attempts
        .map(
          (a) => a.id == id && a.status == AttemptStatus.interrupted
              ? QuestAttempt(
                  id: a.id,
                  questId: a.questId,
                  questVersion: a.questVersion,
                  startedAt: clock().subtract(
                    Duration(seconds: a.elapsedSeconds),
                  ),
                  status: AttemptStatus.active,
                  evidence: a.evidence,
                  elapsedSeconds: a.elapsedSeconds,
                  reflection: a.reflection,
                  timingNote: 'Resumed after an interruption; elapsed time is approximate.',
                )
              : a,
        )
        .toList();
    await _commit(
      PrototypeData(
        attempts: attempts,
        awards: data.awards,
        researchSelections: data.researchSelections,
      ),
    );
  }

  Future<void> selectConcept(String id) async => _commit(
    PrototypeData(
      attempts: data.attempts,
      awards: data.awards,
      researchSelections: {...data.researchSelections, id},
    ),
  );
  Future<void> reset() async {
    await store.clear();
    data = const PrototypeData();
  }

  Future<void> _commit(PrototypeData next) async {
    await store.save(next);
    data = next;
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
