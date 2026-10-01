import 'package:flutter_test/flutter_test.dart';
import 'package:project_irl_phase0/src/models.dart';
import 'package:project_irl_phase0/src/quest_catalog.dart';

void main() {
  test('catalog contains five safe quests for each goal', () {
    expect(questCatalog, hasLength(20));
    for (final domain in SkillDomain.values) {
      final quests = questCatalog.where((quest) => quest.skillDomain == domain);
      expect(quests, hasLength(5));
      expect(quests.every((quest) => quest.riskClass == 'LOW'), isTrue);
      expect(
        quests.every(
          (quest) => quest.allowedEvidenceLabel == EvidenceLabel.selfReported,
        ),
        isTrue,
      );
      expect(
        quests.every((quest) => quest.safetyConstraints.isNotEmpty),
        isTrue,
      );
    }
  });

  test('recommendations are bounded to three and goal-specific', () {
    final recommendations = recommendationsFor(SkillDomain.focus);
    expect(recommendations, hasLength(3));
    expect(
      recommendations.every((quest) => quest.skillDomain == SkillDomain.focus),
      isTrue,
    );
  });
}
