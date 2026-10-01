import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';
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
}

class QuestFlowController extends ChangeNotifier {
  QuestFlowController(this._store);

  final ProgressStore _store;
  FlowStep step = FlowStep.welcome;
  SkillDomain? goal;
  Quest? selectedQuest;
  Duration elapsed = Duration.zero;
  Set<String> completedQuestIds = {};
  ReflectionAnswer? reflection;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  List<Quest> get recommendations =>
      goal == null ? [] : recommendationsFor(goal!);
  int get completionCount => completedQuestIds.length;

  Future<void> initialize() async {
    completedQuestIds = await _store.loadCompletedQuestIds();
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

  void startQuest() {
    elapsed = Duration.zero;
    _timer?.cancel();
    _stopwatch
      ..reset()
      ..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed = _stopwatch.elapsed;
      notifyListeners();
    });
    _go(FlowStep.session);
  }

  void requestCompletion() {
    _timer?.cancel();
    _stopwatch.stop();
    _go(FlowStep.completion);
  }

  void confirmSelfReportedCompletion() => _go(FlowStep.reflection);

  Future<void> submitReflection(ReflectionAnswer answer) async {
    reflection = answer;
    final quest = selectedQuest;
    if (quest != null) {
      completedQuestIds = {...completedQuestIds, quest.id};
      await _store.saveCompletedQuestIds(completedQuestIds);
    }
    _go(FlowStep.evidence);
  }

  void showProgress() => _go(FlowStep.progress);

  void nextQuest() {
    selectedQuest = null;
    reflection = null;
    elapsed = Duration.zero;
    _go(FlowStep.quests);
  }

  void finish() {
    goal = null;
    selectedQuest = null;
    reflection = null;
    elapsed = Duration.zero;
    _go(FlowStep.welcome);
  }

  void cancelQuest() {
    _timer?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    selectedQuest = null;
    elapsed = Duration.zero;
    _go(FlowStep.quests);
  }

  void backToGoals() {
    goal = null;
    selectedQuest = null;
    _go(FlowStep.goals);
  }

  void _go(FlowStep next) {
    step = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}
