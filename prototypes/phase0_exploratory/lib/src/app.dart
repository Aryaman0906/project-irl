import 'package:flutter/material.dart';

import 'flow_controller.dart';
import 'models.dart';
import 'progress_store.dart';
import 'strings.dart';

class ProjectIrlPrototypeApp extends StatefulWidget {
  const ProjectIrlPrototypeApp({super.key, this.progressStore});

  final ProgressStore? progressStore;

  @override
  State<ProjectIrlPrototypeApp> createState() => _ProjectIrlPrototypeAppState();
}

class _ProjectIrlPrototypeAppState extends State<ProjectIrlPrototypeApp> {
  late final QuestFlowController controller;

  @override
  void initState() {
    super.initState();
    controller = QuestFlowController(
      widget.progressStore ?? SharedPreferencesProgressStore(),
    );
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: AppStrings.appName,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315c55)),
      useMaterial3: true,
      textTheme: const TextTheme(bodyLarge: TextStyle(height: 1.45)),
    ),
    home: AnimatedBuilder(
      animation: controller,
      builder: (context, _) => PrototypeShell(controller: controller),
    ),
  );
}

class PrototypeShell extends StatelessWidget {
  const PrototypeShell({super.key, required this.controller});

  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.appName),
          Text(
            AppStrings.prototypeLabel,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _currentScreen(),
          ),
        ),
      ),
    ),
  );

  Widget _currentScreen() => switch (controller.step) {
    FlowStep.welcome => WelcomeScreen(onBegin: controller.begin),
    FlowStep.goals => GoalScreen(onSelected: controller.selectGoal),
    FlowStep.quests => QuestOptionsScreen(controller: controller),
    FlowStep.details => QuestDetailsScreen(controller: controller),
    FlowStep.session => SessionScreen(controller: controller),
    FlowStep.completion => CompletionScreen(controller: controller),
    FlowStep.reflection => ReflectionScreen(controller: controller),
    FlowStep.evidence => EvidenceScreen(controller: controller),
    FlowStep.progress => ProgressScreen(controller: controller),
  };
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onBegin});
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) => _Page(
    title: AppStrings.welcomeTitle,
    children: [
      const Text(AppStrings.welcomeBody),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: onBegin,
        icon: const Icon(Icons.explore_outlined),
        label: const Text(AppStrings.begin),
      ),
    ],
  );
}

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key, required this.onSelected});
  final ValueChanged<SkillDomain> onSelected;

  @override
  Widget build(BuildContext context) => _Page(
    title: AppStrings.selectGoal,
    subtitle: 'There is no best choice. Pick what feels useful right now.',
    children: SkillDomain.values
        .map(
          (goal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              button: true,
              label: 'Choose ${_domainName(goal)} goal',
              child: Card(
                child: ListTile(
                  minVerticalPadding: 16,
                  title: Text(_domainName(goal)),
                  subtitle: Text(_domainDescription(goal)),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => onSelected(goal),
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

class QuestOptionsScreen extends StatelessWidget {
  const QuestOptionsScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) => _Page(
    title: AppStrings.chooseQuest,
    subtitle:
        'Three local suggestions because you chose ${_domainName(controller.goal!)}. You stay in control.',
    children: [
      ...controller.recommendations.map(
        (quest) => Card(
          child: ListTile(
            minVerticalPadding: 14,
            title: Text(quest.title),
            subtitle: Text('${quest.estimatedMinutes} minutes · offline'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => controller.chooseQuest(quest),
          ),
        ),
      ),
      TextButton.icon(
        onPressed: controller.backToGoals,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Choose another goal'),
      ),
    ],
  );
}

class QuestDetailsScreen extends StatelessWidget {
  const QuestDetailsScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) {
    final quest = controller.selectedQuest!;
    return _Page(
      title: quest.title,
      children: [
        Text(quest.description),
        const SizedBox(height: 16),
        _InfoRow(
          icon: Icons.schedule,
          text: 'About ${quest.estimatedMinutes} minutes offline',
        ),
        const _InfoRow(
          icon: Icons.shield_outlined,
          text: 'Low-risk prototype quest',
        ),
        const SizedBox(height: 16),
        Text('Keep it safe', style: Theme.of(context).textTheme.titleMedium),
        ...quest.safetyConstraints.map(
          (text) => ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(text),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const Text(
          'The timer only measures time in this app. It does not prove what happened offline.',
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: controller.startQuest,
          child: const Text(AppStrings.start),
        ),
        TextButton(
          onPressed: controller.cancelQuest,
          child: const Text('Choose a different quest'),
        ),
      ],
    );
  }
}

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) {
    final elapsed = controller.elapsed;
    final time =
        '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    return _Page(
      title: 'Quest in progress',
      subtitle: controller.selectedQuest!.title,
      children: [
        Semantics(
          label: 'Elapsed time $time',
          liveRegion: true,
          child: Text(time, style: Theme.of(context).textTheme.displayLarge),
        ),
        const SizedBox(height: 16),
        const Text(
          'You can put the phone aside now. Return when you choose to finish or cancel.',
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: controller.requestCompletion,
          child: const Text(AppStrings.complete),
        ),
        TextButton(
          onPressed: controller.cancelQuest,
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }
}

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) => _Page(
    title: AppStrings.completionQuestion,
    children: [
      const Text(
        'Your answer is a self-report. The timer cannot verify the real-world activity.',
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: controller.confirmSelfReportedCompletion,
        child: const Text(AppStrings.yesSelfReport),
      ),
      OutlinedButton(
        onPressed: controller.cancelQuest,
        child: const Text(AppStrings.notThisTime),
      ),
    ],
  );
}

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  String? difficulty;
  String? helped;

  @override
  Widget build(BuildContext context) => _Page(
    title: AppStrings.reflectionTitle,
    subtitle: 'Choose what fits. There are no good or bad answers.',
    children: [
      Text(
        'How difficult was it?',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      RadioGroup<String>(
        groupValue: difficulty,
        onChanged: (value) => setState(() => difficulty = value),
        child: Column(
          children: ['Easy', 'Manageable', 'Difficult']
              .map(
                (value) =>
                    RadioListTile<String>(title: Text(value), value: value),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 12),
      Text('What helped most?', style: Theme.of(context).textTheme.titleMedium),
      RadioGroup<String>(
        groupValue: helped,
        onChanged: (value) => setState(() => helped = value),
        child: Column(
          children:
              [
                    'Quiet environment',
                    'Clear task',
                    'Phone away',
                    'Something else',
                  ]
                  .map(
                    (value) =>
                        RadioListTile<String>(title: Text(value), value: value),
                  )
                  .toList(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: difficulty == null || helped == null
            ? null
            : () => widget.controller.submitReflection(
                ReflectionAnswer(difficulty: difficulty!, helpedMost: helped!),
              ),
        child: const Text('Continue'),
      ),
    ],
  );
}

class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) => _Page(
    title: AppStrings.evidenceTitle,
    children: [
      const _EvidenceCard(
        label: 'SELF_REPORTED',
        explanation: 'You reported that the activity happened. The app did not independently observe the real-world activity.',
      ),
      const _EvidenceCard(
        label: 'DEVICE_VERIFIED',
        explanation: 'In a future approved feature, this could mean a permitted device condition was observed. It would not prove the underlying activity.',
      ),
      const _EvidenceCard(
        label: 'UNVERIFIABLE',
        explanation: 'Some internal experiences cannot be legitimately verified. They should remain reflection, not a score.',
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: controller.showProgress,
        child: const Text('See local progress'),
      ),
    ],
  );
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) => _Page(
    title: AppStrings.progressTitle,
    children: [
      Text(
        '${controller.completionCount}',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const Text('different quests reported complete on this device'),
      const SizedBox(height: 12),
      const Text(
        'This is not a morality score, rank, streak, or production reward. Missing a day changes nothing.',
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: controller.nextQuest,
        child: const Text('Choose another quest'),
      ),
      TextButton(
        onPressed: controller.finish,
        child: const Text('Finish for now'),
      ),
    ],
  );
}

class _Page extends StatelessWidget {
  const _Page({required this.title, this.subtitle, required this.children});
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!)],
        const SizedBox(height: 24),
        ...children,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(text),
    contentPadding: EdgeInsets.zero,
  );
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.label, required this.explanation});
  final String label;
  final String explanation;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(explanation),
        ],
      ),
    ),
  );
}

String _domainName(SkillDomain domain) => switch (domain) {
  SkillDomain.focus => 'Focus',
  SkillDomain.responsibility => 'Responsibility',
  SkillDomain.listening => 'Listening',
  SkillDomain.gratitude => 'Gratitude',
};

String _domainDescription(SkillDomain domain) => switch (domain) {
  SkillDomain.focus => 'Stay with one chosen task for a short time.',
  SkillDomain.responsibility => 'Take care of one practical commitment.',
  SkillDomain.listening => 'Give attention without recording or judging.',
  SkillDomain.gratitude => 'Notice support without pressure to perform.',
};
