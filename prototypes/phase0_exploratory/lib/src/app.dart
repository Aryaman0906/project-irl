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

class _ProjectIrlPrototypeAppState extends State<ProjectIrlPrototypeApp>
    with WidgetsBindingObserver {
  late final QuestFlowController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = QuestFlowController(
      widget.progressStore ?? SharedPreferencesProgressStore(),
    );
    controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.checkpoint();
    }
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
      actions: [
        IconButton(
          tooltip: 'Local privacy and reset',
          onPressed: controller.showPrivacy,
          icon: const Icon(Icons.privacy_tip_outlined),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: controller.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Loading local progress',
                    ),
                  )
                : Column(
                    children: [
                      if (controller.error != null)
                        MaterialBanner(
                          content: Text(controller.error!),
                          actions: [
                            TextButton(
                              onPressed: controller.dismissError,
                              child: const Text('Dismiss'),
                            ),
                          ],
                        ),
                      Expanded(child: _currentScreen()),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );

  Widget _currentScreen() => switch (controller.step) {
    FlowStep.welcome => WelcomeScreen(
      onBegin: controller.begin,
      controller: controller,
    ),
    FlowStep.goals => GoalScreen(onSelected: controller.selectGoal),
    FlowStep.quests => QuestOptionsScreen(controller: controller),
    FlowStep.details => QuestDetailsScreen(controller: controller),
    FlowStep.session => SessionScreen(controller: controller),
    FlowStep.completion => CompletionScreen(controller: controller),
    FlowStep.reflection => ReflectionScreen(controller: controller),
    FlowStep.evidence => EvidenceScreen(controller: controller),
    FlowStep.progress => ProgressScreen(controller: controller),
    FlowStep.concepts => ConceptsScreen(controller: controller),
    FlowStep.privacy => PrivacyScreen(controller: controller),
  };
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onBegin, this.controller});
  final VoidCallback onBegin;
  final QuestFlowController? controller;

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
      const SizedBox(height: 12),
      if (controller != null) ...[
        OutlinedButton(
          onPressed: controller!.showProgress,
          child: const Text('View progress and history'),
        ),
        TextButton(
          onPressed: controller!.showConcepts,
          child: const Text('Explore concepts (research only)'),
        ),
      ],
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
      title: controller.currentAttempt?.status == AttemptStatus.interrupted
          ? 'Timing interrupted'
          : 'Quest in progress',
      subtitle:
          controller.selectedQuest?.title ?? controller.currentAttempt?.questId,
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
        if (controller.currentAttempt?.status == AttemptStatus.interrupted) ...[
          const SizedBox(height: 12),
          const Text(
            'The app was closed or timing became uncertain. The activity was not verified and no XP was granted.',
          ),
          OutlinedButton(
            onPressed: controller.resumeInterrupted,
            child: const Text('Resume approximate timer'),
          ),
        ],
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
  final note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

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
      TextField(
        controller: note,
        maxLength: 240,
        decoration: const InputDecoration(
          labelText: 'Optional private note (skip if you prefer)',
          border: OutlineInputBorder(),
        ),
      ),
      FilledButton(
        onPressed: difficulty == null || helped == null
            ? null
            : () => widget.controller.submitReflection(
                ReflectionAnswer(
                  difficulty: difficulty!,
                  helpedMost: helped!,
                  note: note.text,
                ),
              ),
        child: const Text('Continue'),
      ),
      TextButton(
        onPressed: () => widget.controller.submitReflection(
          const ReflectionAnswer(difficulty: 'Skipped', helpedMost: 'Skipped'),
        ),
        child: const Text('Skip reflection'),
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
      const SizedBox(height: 12),
      Text(controller.lastCompletion?.explanation ?? 'Completion recorded.'),
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
        '${controller.totalXp} XP',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const Text(
        'Non-cash, non-transferable participation progress. XP cannot be spent and creates no entitlement.',
      ),
      const SizedBox(height: 12),
      Text(
        '${controller.weeklyParticipation} completed attempt(s) this local Monday–Sunday week',
      ),
      Text(
        'Participation milestone ${controller.milestoneIndex + 1}${controller.nextMilestone == null ? ' · highest prototype milestone' : ' · next at ${controller.nextMilestone} XP'}',
      ),
      const SizedBox(height: 12),
      const Text(
        'This is not a morality score, rank, streak, or production reward. Missing a day changes nothing.',
      ),
      const Divider(height: 32),
      Text('Recent attempts', style: Theme.of(context).textTheme.titleLarge),
      if (controller.attempts.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No attempts yet. Completed, cancelled and interrupted quests will appear here.',
          ),
        ),
      ...controller.attempts.take(10).map((attempt) {
        final matchingAwards = controller.awards.where(
          (a) => a.attemptId == attempt.id,
        );
        final award = matchingAwards.isEmpty ? null : matchingAwards.first;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(attempt.questId),
          subtitle: Text(
            '${attempt.status.name.toUpperCase()} · ${_evidenceName(attempt.evidence)}${award == null ? ' · no XP' : ' · +${award.amount} XP (${award.reasonCode})'}',
          ),
        );
      }),
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

class ConceptsScreen extends StatelessWidget {
  const ConceptsScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) => _Page(
    title: 'Explore concepts',
    subtitle: 'Separate research preview — nothing here can buy, redeem, subscribe, or change XP.',
    children: [
      const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Research concept only. Purchases and redemption are unavailable. XP has no cash value and creates no entitlement to future rewards.',
          ),
        ),
      ),
      Text(
        'Possible optional subscription',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const Text(
        'Free core would keep quests, participation, history, privacy controls and all accumulated XP. A hypothetical option could add curated activity packs, printable family activities, planning tools and themes. No price or availability is proposed.',
      ),
      OutlinedButton(
        onPressed: () =>
            controller.selectConcept('subscription-optional-content'),
        child: Text(
          controller.researchSelections.contains(
                'subscription-optional-content',
              )
              ? 'Interest saved locally'
              : 'This optional content interests me',
        ),
      ),
      const Divider(height: 32),
      Text(
        'Illustrative shop categories',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const Text(
        'Which category would interest you? This does not place an order or reserve stock. No merchant partnership is implied.',
      ),
      for (final category in const {
        'activity-kits': 'Colouring and activity kits',
        'toys': 'Age-appropriate toys',
        'pet-accessories': 'Non-consumable pet accessories',
        'generic-voucher': 'Generic shopping-voucher concept',
      }.entries)
        CheckboxListTile(
          value: controller.researchSelections.contains(category.key),
          onChanged: controller.researchSelections.contains(category.key)
              ? null
              : (_) => controller.selectConcept(category.key),
          title: Text(category.value),
          subtitle: const Text('Research preference only'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      TextButton(
        onPressed: controller.finish,
        child: const Text('Back to start'),
      ),
    ],
  );
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.controller});
  final QuestFlowController controller;

  @override
  Widget build(BuildContext context) => _Page(
    title: 'Local data and privacy',
    children: [
      const Text(
        'This prototype stores quest attempts, timestamps, status, self-reported evidence labels, optional reflections, XP ledger entries and research preferences in this app’s local shared-preferences storage. It sends none of this to a backend.',
      ),
      const SizedBox(height: 12),
      const Text(
        'Local storage is not tamper-proof, may be removed by uninstalling or clearing app data, and is not a backup or protection against a modified app. Do not enter names, contact details, addresses, payment/bank/UPI details, identity documents or information about another person.',
      ),
      const SizedBox(height: 24),
      FilledButton.tonalIcon(
        icon: const Icon(Icons.delete_forever),
        label: const Text('Delete all local prototype data'),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete all local data?'),
              content: const Text(
                'This removes attempts, reflections, XP awards, active timing and research selections. This cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep data'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete all'),
                ),
              ],
            ),
          );
          if (confirmed == true) await controller.reset();
        },
      ),
      TextButton(
        onPressed: controller.finish,
        child: const Text('Back to start'),
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

String _evidenceName(EvidenceLabel label) => switch (label) {
  EvidenceLabel.deviceVerified => 'DEVICE_VERIFIED',
  EvidenceLabel.witnessConfirmed => 'WITNESS_CONFIRMED',
  EvidenceLabel.outcomeSupported => 'OUTCOME_SUPPORTED',
  EvidenceLabel.selfReported => 'SELF_REPORTED',
  EvidenceLabel.unverifiable => 'UNVERIFIABLE',
};
