import 'package:flutter_test/flutter_test.dart';
import 'package:project_irl_phase0/src/flow_controller.dart';
import 'package:project_irl_phase0/src/models.dart';
import 'package:project_irl_phase0/src/progress_store.dart';

void main() {
  test('completion persists once and cancel never adds progress', () async {
    final store = MemoryProgressStore();
    final controller = QuestFlowController(store);
    await controller.initialize();

    controller.begin();
    controller.selectGoal(SkillDomain.focus);
    controller.chooseQuest(controller.recommendations.first);
    controller.startQuest();
    controller.requestCompletion();
    controller.confirmSelfReportedCompletion();
    await controller.submitReflection(
      const ReflectionAnswer(
        difficulty: 'Manageable',
        helpedMost: 'Clear task',
      ),
    );

    expect(controller.step, FlowStep.evidence);
    expect(controller.completionCount, 1);
    expect((await store.loadCompletedQuestIds()), hasLength(1));

    controller.nextQuest();
    controller.chooseQuest(controller.recommendations[1]);
    controller.startQuest();
    controller.cancelQuest();
    expect(controller.completionCount, 1);
    controller.dispose();
  });

  test('initialization restores local completed identifiers', () async {
    final store = MemoryProgressStore()..ids = {'focus-01', 'gratitude-01'};
    final controller = QuestFlowController(store);
    await controller.initialize();
    expect(controller.completionCount, 2);
    controller.dispose();
  });
}
