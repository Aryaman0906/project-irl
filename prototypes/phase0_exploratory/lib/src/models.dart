enum SkillDomain { focus, responsibility, listening, gratitude }

enum EvidenceLabel {
  deviceVerified,
  witnessConfirmed,
  outcomeSupported,
  selfReported,
  unverifiable,
}

enum AttemptStatus { active, interrupted, completed, cancelled, abandoned }

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
  const ReflectionAnswer({
    required this.difficulty,
    required this.helpedMost,
    this.note,
  });
  final String difficulty;
  final String helpedMost;
  final String? note;
  Map<String, Object?> toJson() => {
    'difficulty': difficulty,
    'helpedMost': helpedMost,
    if (note?.trim().isNotEmpty ?? false) 'note': note!.trim(),
  };
  factory ReflectionAnswer.fromJson(Map<String, dynamic> json) =>
      ReflectionAnswer(
        difficulty: json['difficulty'] as String? ?? 'Skipped',
        helpedMost: json['helpedMost'] as String? ?? 'Skipped',
        note: json['note'] as String?,
      );
}

class QuestAttempt {
  const QuestAttempt({
    required this.id,
    required this.questId,
    required this.questVersion,
    required this.startedAt,
    required this.status,
    required this.evidence,
    this.endedAt,
    this.elapsedSeconds = 0,
    this.reflection,
    this.timingNote,
  });
  final String id;
  final String questId;
  final int questVersion;
  final DateTime startedAt;
  final DateTime? endedAt;
  final AttemptStatus status;
  final EvidenceLabel evidence;
  final int elapsedSeconds;
  final ReflectionAnswer? reflection;
  final String? timingNote;
  QuestAttempt copyWith({
    DateTime? endedAt,
    AttemptStatus? status,
    int? elapsedSeconds,
    ReflectionAnswer? reflection,
    String? timingNote,
  }) => QuestAttempt(
    id: id,
    questId: questId,
    questVersion: questVersion,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    status: status ?? this.status,
    evidence: evidence,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    reflection: reflection ?? this.reflection,
    timingNote: timingNote ?? this.timingNote,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'questId': questId,
    'questVersion': questVersion,
    'startedAt': startedAt.toUtc().toIso8601String(),
    if (endedAt != null) 'endedAt': endedAt!.toUtc().toIso8601String(),
    'status': status.name,
    'evidence': evidence.name,
    'elapsedSeconds': elapsedSeconds,
    if (reflection != null) 'reflection': reflection!.toJson(),
    if (timingNote != null) 'timingNote': timingNote,
  };
  factory QuestAttempt.fromJson(Map<String, dynamic> json) => QuestAttempt(
    id: json['id'] as String,
    questId: json['questId'] as String,
    questVersion: json['questVersion'] as int? ?? 1,
    startedAt: DateTime.parse(json['startedAt'] as String).toLocal(),
    endedAt: json['endedAt'] == null
        ? null
        : DateTime.parse(json['endedAt'] as String).toLocal(),
    status: AttemptStatus.values.byName(json['status'] as String),
    evidence: EvidenceLabel.values.byName(
      json['evidence'] as String? ?? 'selfReported',
    ),
    elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
    reflection: json['reflection'] == null
        ? null
        : ReflectionAnswer.fromJson(
            Map<String, dynamic>.from(json['reflection'] as Map),
          ),
    timingNote: json['timingNote'] as String?,
  );
}

class XpAward {
  const XpAward({
    required this.id,
    required this.attemptId,
    required this.amount,
    required this.reasonCode,
    required this.policyVersion,
    required this.awardedAt,
  });
  final String id;
  final String attemptId;
  final int amount;
  final String reasonCode;
  final int policyVersion;
  final DateTime awardedAt;
  Map<String, Object?> toJson() => {
    'id': id,
    'attemptId': attemptId,
    'amount': amount,
    'reasonCode': reasonCode,
    'policyVersion': policyVersion,
    'awardedAt': awardedAt.toUtc().toIso8601String(),
  };
  factory XpAward.fromJson(Map<String, dynamic> json) => XpAward(
    id: json['id'] as String,
    attemptId: json['attemptId'] as String,
    amount: json['amount'] as int,
    reasonCode: json['reasonCode'] as String,
    policyVersion: json['policyVersion'] as int,
    awardedAt: DateTime.parse(json['awardedAt'] as String).toLocal(),
  );
}

class PrototypeData {
  const PrototypeData({
    this.attempts = const [],
    this.awards = const [],
    this.researchSelections = const {},
  });
  final List<QuestAttempt> attempts;
  final List<XpAward> awards;
  final Set<String> researchSelections;
  int get totalXp => awards.fold(0, (sum, award) => sum + award.amount);
  Map<String, Object?> toJson() => {
    'schemaVersion': 2,
    'attempts': attempts.map((e) => e.toJson()).toList(),
    'awards': awards.map((e) => e.toJson()).toList(),
    'researchSelections': researchSelections.toList()..sort(),
  };
  factory PrototypeData.fromJson(Map<String, dynamic> json) => PrototypeData(
    attempts: (json['attempts'] as List? ?? [])
        .map((e) => QuestAttempt.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    awards: (json['awards'] as List? ?? [])
        .map((e) => XpAward.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    researchSelections: Set<String>.from(
      json['researchSelections'] as List? ?? [],
    ),
  );
}
