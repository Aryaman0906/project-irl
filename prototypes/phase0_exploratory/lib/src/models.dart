enum SkillDomain { focus, responsibility, listening, gratitude }

enum EvidenceLabel {
  deviceVerified,
  witnessConfirmed,
  outcomeSupported,
  selfReported,
  unverifiable,
}

class Quest {
  const Quest({
    required this.id,
    required this.version,
    required this.title,
    required this.description,
    required this.skillDomain,
    required this.minimumAge,
    required this.maximumAge,
    required this.riskClass,
    required this.estimatedMinutes,
    required this.reflectionPolicy,
    required this.allowedEvidenceLabel,
    required this.safetyConstraints,
  });

  final String id;
  final int version;
  final String title;
  final String description;
  final SkillDomain skillDomain;
  final int minimumAge;
  final int maximumAge;
  final String riskClass;
  final int estimatedMinutes;
  final String reflectionPolicy;
  final EvidenceLabel allowedEvidenceLabel;
  final List<String> safetyConstraints;
}

class ReflectionAnswer {
  const ReflectionAnswer({required this.difficulty, required this.helpedMost});

  final String difficulty;
  final String helpedMost;
}
