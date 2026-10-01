import 'models.dart';

const _standardSafety = <String>[
  'Choose a familiar, safe place.',
  'Stop if anything feels uncomfortable or unsafe.',
  'Do not share private information or record another person.',
];

Quest _quest(
  String id,
  String title,
  String description,
  SkillDomain domain,
  int minutes, {
  List<String> safety = _standardSafety,
}) => Quest(
  id: id,
  version: 1,
  title: title,
  description: description,
  skillDomain: domain,
  minimumAge: 12,
  maximumAge: 17,
  riskClass: 'LOW',
  estimatedMinutes: minutes,
  reflectionPolicy: 'STRUCTURED_OPTIONAL_NO_FREE_TEXT',
  allowedEvidenceLabel: EvidenceLabel.selfReported,
  safetyConstraints: safety,
);

final questCatalog = <Quest>[
  _quest(
    'focus-01',
    'One-task focus',
    'Put your phone aside and work on one chosen school or personal task.',
    SkillDomain.focus,
    20,
  ),
  _quest(
    'focus-02',
    'Read one section',
    'Read a short chapter or article section, then pause to recall three points.',
    SkillDomain.focus,
    15,
  ),
  _quest(
    'focus-03',
    'Desk reset',
    'Clear only the space you need, choose one task, and work without switching.',
    SkillDomain.focus,
    12,
  ),
  _quest(
    'focus-04',
    'Paper plan',
    'On paper, choose the next three steps for a task and complete the first one.',
    SkillDomain.focus,
    15,
  ),
  _quest(
    'focus-05',
    'Mindful sketch',
    'Observe a nearby everyday object and sketch its shapes without judging the result.',
    SkillDomain.focus,
    10,
  ),
  _quest(
    'responsibility-01',
    'Prepare tomorrow',
    'Pack the items you expect to need tomorrow using your own checklist.',
    SkillDomain.responsibility,
    10,
  ),
  _quest(
    'responsibility-02',
    'Tidy one small area',
    'Choose one small area you are allowed to organize and leave it usable.',
    SkillDomain.responsibility,
    12,
  ),
  _quest(
    'responsibility-03',
    'Finish one small promise',
    'Complete one safe, realistic task you already agreed to do.',
    SkillDomain.responsibility,
    15,
  ),
  _quest(
    'responsibility-04',
    'Refill and return',
    'Refill your water bottle and return one shared item to its usual place.',
    SkillDomain.responsibility,
    5,
  ),
  _quest(
    'responsibility-05',
    'Check before leaving',
    'Use a short paper checklist to check what you need before your next activity.',
    SkillDomain.responsibility,
    7,
  ),
  _quest(
    'listening-01',
    'Listen without fixing',
    'Ask someone you know about their day and listen without immediately giving advice.',
    SkillDomain.listening,
    10,
  ),
  _quest(
    'listening-02',
    'Three details',
    'During a safe conversation, notice three details the other person chose to share.',
    SkillDomain.listening,
    10,
  ),
  _quest(
    'listening-03',
    'Reflect back',
    'In a conversation with someone you know, briefly reflect what you heard and let them correct you.',
    SkillDomain.listening,
    8,
  ),
  _quest(
    'listening-04',
    'Question and pause',
    'Ask one open question, then leave space for the other person to answer.',
    SkillDomain.listening,
    8,
  ),
  _quest(
    'listening-05',
    'Sound map',
    'Sit in a safe familiar place and quietly notice five ordinary sounds around you.',
    SkillDomain.listening,
    5,
  ),
  _quest(
    'gratitude-01',
    'Specific thanks',
    'Thank someone you know for one specific action, without expecting a response.',
    SkillDomain.gratitude,
    5,
  ),
  _quest(
    'gratitude-02',
    'Notice three supports',
    'On paper, note three ordinary things that helped your day go more smoothly.',
    SkillDomain.gratitude,
    7,
  ),
  _quest(
    'gratitude-03',
    'Care for an object',
    'Clean or put away one item you use often as a way of appreciating it.',
    SkillDomain.gratitude,
    8,
  ),
  _quest(
    'gratitude-04',
    'Quiet appreciation',
    'Spend a few minutes noticing something in nature from a safe familiar place.',
    SkillDomain.gratitude,
    5,
  ),
  _quest(
    'gratitude-05',
    'Write an unsent note',
    'Write a short private thank-you note. You choose whether to share it.',
    SkillDomain.gratitude,
    10,
  ),
];

List<Quest> recommendationsFor(SkillDomain goal, {int limit = 3}) =>
    questCatalog
        .where((quest) => quest.skillDomain == goal)
        .take(limit)
        .toList();
