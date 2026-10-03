import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';
import 'progress_service.dart';
import 'progress_store.dart';
import 'quest_catalog.dart';

enum FlowStep {
  welcome,
  goals,
  quests,
  details,
  session,
  completion,
  reflection,
  evidence,
  progress,
  concepts,
  privacy,
}

class QuestFlowController extends ChangeNotifier {
  QuestFlowController(ProgressStore store, {Clock? clock})
    : service = ProgressService(store, clock: clock);
  final ProgressService service;
  FlowStep step = FlowStep.welcome;
  SkillDomain? goal;
  Quest? selectedQuest;
  QuestAttempt? currentAttempt;
  Duration elapsed = Duration.zero;
  ReflectionAnswer? reflection;
  CompletionResult? lastCompletion;
  String? error;
  bool loading = true;
  Timer? _timer;

  List<Quest> get recommendations =>
      goal == null ? [] : recommendationsFor(goal!);
  List<QuestAttempt> get attempts => service.data.attempts.reversed.toList();
  List<XpAward> get awards => service.data.awards;
  int get totalXp => service.data.totalXp;
  int get completionCount =>
      attempts.where((a) => a.status == AttemptStatus.completed).length;
  Set<String> get researchSelections => service.data.researchSelections;
  int get weeklyParticipation {
    final now = service.clock();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return attempts
        .where(
          (a) =>
              a.status == AttemptStatus.completed &&
              (a.endedAt?.isBefore(start) == false),
        )
        .length;
  }

  int get milestoneIndex {
    var index = 0;
    for (var i = 0; i < RewardPolicy.milestoneThresholds.length; i++) {
      if (totalXp >= RewardPolicy.milestoneThresholds[i]) index = i;
    }
    return index;
  }

  int? get nextMilestone =>
      milestoneIndex + 1 < RewardPolicy.milestoneThresholds.length
      ? RewardPolicy.milestoneThresholds[milestoneIndex + 1]
      : null;

  Future<void> initialize() async {
    try {
      await service.initialize();
      currentAttempt = service.activeAttempt;
      if (currentAttempt != null) {
        selectedQuest = questCatalog
            .where((q) => q.id == currentAttempt!.questId)
            .firstOrNull;
        elapsed = Duration(seconds: currentAttempt!.elapsedSeconds);
        step = FlowStep.session;
      }
    } on Object catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  void begin() => _go(FlowStep.goals);
  void selectGoal(SkillDomain value) {
    goal = value;
    _go(FlowStep.quests);
  }

  void chooseQuest(Quest value) {
    selectedQuest = value;
    _go(FlowStep.details);
  }

  Future<void> startQuest() async {
    final quest = selectedQuest!;
    try {
      currentAttempt = await service.start(quest);
      elapsed = Duration.zero;
      _startTicker();
      _go(FlowStep.session);
    } on Object catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final attempt = currentAttempt;
      if (attempt == null) return;
      final delta = service.clock().difference(attempt.startedAt);
      if (delta.isNegative) {
        await service.checkpoint(attempt.id);
        currentAttempt = service.activeAttempt;
        _timer?.cancel();
      } else {
        elapsed = delta;
      }
      notifyListeners();
    });
  }

  Future<void> checkpoint() async {
    final attempt = currentAttempt;
    if (attempt != null && attempt.status == AttemptStatus.active) {
      try {
        await service.checkpoint(attempt.id);
        currentAttempt = service.activeAttempt;
      } on Object catch (e) {
        error = e.toString();
      }
      notifyListeners();
    }
  }

  void requestCompletion() {
    _timer?.cancel();
    _go(FlowStep.completion);
  }

  void confirmSelfReportedCompletion() => _go(FlowStep.reflection);
  Future<void> submitReflection(ReflectionAnswer answer) async {
    final attempt = currentAttempt;
    if (attempt == null) return;
    try {
      reflection = answer;
      lastCompletion = await service.complete(attempt.id, answer);
      currentAttempt = lastCompletion!.attempt;
      _go(FlowStep.evidence);
    } on Object catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void showProgress() => _go(FlowStep.progress);
  void showConcepts() => _go(FlowStep.concepts);
  void showPrivacy() => _go(FlowStep.privacy);
  Future<void> selectConcept(String id) async {
    try {
      await service.selectConcept(id);
    } on Object catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> reset() async {
    try {
      await service.reset();
      goal = null;
      selectedQuest = null;
      currentAttempt = null;
      reflection = null;
      lastCompletion = null;
      elapsed = Duration.zero;
      error = null;
      _go(FlowStep.welcome);
    } on Object catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void nextQuest() {
    selectedQuest = null;
    currentAttempt = null;
    reflection = null;
    elapsed = Duration.zero;
    _go(FlowStep.quests);
  }

  void finish() {
    goal = null;
    selectedQuest = null;
    currentAttempt = null;
    reflection = null;
    elapsed = Duration.zero;
    _go(FlowStep.welcome);
  }

  Future<void> cancelQuest() async {
    final attempt = currentAttempt;
    _timer?.cancel();
    if (attempt != null) {
      try {
        await service.cancel(attempt.id);
      } on Object catch (e) {
        error = e.toString();
        notifyListeners();
        return;
      }
    }
    currentAttempt = null;
    selectedQuest = null;
    elapsed = Duration.zero;
    _go(goal == null ? FlowStep.goals : FlowStep.quests);
  }

  Future<void> resumeInterrupted() async {
    final attempt = currentAttempt;
    if (attempt == null) return;
    try {
      await service.resume(attempt.id);
      currentAttempt = service.activeAttempt;
      _startTicker();
    } on Object catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  void backToGoals() {
    goal = null;
    selectedQuest = null;
    _go(FlowStep.goals);
  }

  void dismissError() {
    error = null;
    notifyListeners();
  }

  void _go(FlowStep next) {
    step = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
