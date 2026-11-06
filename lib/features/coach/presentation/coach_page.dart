import 'package:flutter/material.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/l10n/app_strings.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/features/coach/application/coach_controller.dart';
import 'package:moreki/features/coach/domain/coach_models.dart';

/// Feature name -> translation key for its "Open ..." button.
const Map<String, String> _featureLabelKeys = {
  'money': 'coach.open.money',
  'salaryDiagnosis': 'coach.open.salaryDiagnosis',
  'creditScore': 'coach.open.creditScore',
  'taxReturn': 'coach.open.taxReturn',
  'emergencyFund': 'coach.open.emergencyFund',
  'familyContribution': 'coach.open.familyContribution',
  'sideHustle': 'coach.open.sideHustle',
  'insuranceGuide': 'coach.open.insuranceGuide',
  'crisisMode': 'coach.open.crisisMode',
};

/// The saved answers, topic names and sources come from an English-only
/// asset. Only the standard English asset messages are swapped for the
/// chosen language; anything else is shown exactly as saved.
String _assetOrTranslated(
  BuildContext context,
  String assetText,
  String key,
) {
  final lang = AppLanguage.of(context);
  if (assetText.isEmpty || assetText == const AppStrings('en').get(key)) {
    return lang.get(key);
  }
  return assetText;
}

/// The "Ask Moreki" screen: saved answers to money questions.
/// It never pretends to be live AI.
class CoachPage extends StatefulWidget {
  const CoachPage({
    super.key,
    required this.controller,
    this.availableFeatures = const <String>{},
    this.onOpenFeature,
  });

  final CoachController controller;

  /// Feature names that really exist in the app right now. An answer only
  /// shows an "Open" button for a feature in this set.
  final Set<String> availableFeatures;

  final ValueChanged<String>? onOpenFeature;

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scroll.hasClients) return;
    if (MediaQuery.of(context).disableAnimations) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _askTyped() {
    FocusScope.of(context).unfocus();
    widget.controller.ask(_text.text);
    _scrollToTop();
  }

  void _askEntry(CoachEntry entry) {
    if (entry.questions.isNotEmpty) _text.text = entry.questions.first;
    widget.controller.askEntry(entry);
    _scrollToTop();
  }

  void _pickSuggestedTopic(String topicId) {
    final c = widget.controller;
    if (c.selectedTopicId != topicId) c.selectTopic(topicId);
    c.clearAnswer();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = AppLanguage.of(context);

    return Scaffold(
      body: AccentGlow(
        color: AppColors.green,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: lang.get('coach.back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text('Ask Moreki', style: text.headlineMedium),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) => _buildBody(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final lang = AppLanguage.of(context);
    final c = widget.controller;
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    switch (c.state) {
      case CoachLoadState.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.green),
        );
      case CoachLoadState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang.get('coach.loadError'),
                  textAlign: TextAlign.center,
                  style: text.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: c.load,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.darkBackground,
                    minimumSize: const Size(0, 48),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                  ),
                  child: Text(lang.get('coach.retry')),
                ),
              ],
            ),
          ),
        );
      case CoachLoadState.ready:
        break;
    }

    final data = c.data!;
    final match = c.match;

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        _DisclaimerNote(
          text: _assetOrTranslated(
            context,
            data.disclaimer,
            'coach.disclaimer',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _QuestionField(controller: _text, onSubmit: _askTyped),
        const SizedBox(height: AppSpacing.xl),
        if (match != null) ...[
          if (match.best != null) ..._answerWidgets(context, data, match)
          else
            _NoMatchCard(
              message: _assetOrTranslated(
                context,
                data.noMatchMessage,
                'coach.noMatch',
              ),
              suggested: match.suggestedTopics.length < data.topics.length
                  ? match.suggestedTopics
                  : const <CoachTopic>[],
              onPickTopic: _pickSuggestedTopic,
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
        _SectionLabel(lang.get('coach.topics')),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final topic in data.topics)
              _TopicChip(
                label: topic.label,
                selected: c.selectedTopicId == topic.id,
                onTap: () => c.selectTopic(topic.id),
              ),
          ],
        ),
        if (c.selectedTopicId != null) ...[
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(lang.get('coach.questions')),
          for (final entry in c.entriesInSelectedTopic)
            if (entry.questions.isNotEmpty)
              MorekiDataRow(
                title: entry.questions.first,
                onTap: () => _askEntry(entry),
              ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          lang.get('coach.outOfDate'),
          style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
        ),
      ],
    );
  }

  List<Widget> _answerWidgets(
    BuildContext context,
    CoachData data,
    dynamic match,
  ) {
    final lang = AppLanguage.of(context);
    final c = widget.controller;
    final CoachEntry best = match.best as CoachEntry;
    final List<CoachEntry> related = match.related as List<CoachEntry>;

    final feature = best.openFeature;
    final canOpen = feature != null &&
        widget.availableFeatures.contains(feature) &&
        widget.onOpenFeature != null;

    return [
      _AnswerCard(
        entry: best,
        data: data,
        opener: c.openerFor(best),
        openLabel: canOpen
            ? lang.get(_featureLabelKeys[feature] ?? 'coach.open')
            : null,
        onOpen: canOpen ? () => widget.onOpenFeature!(feature) : null,
      ),
      if (related.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        _SectionLabel(lang.get('coach.related')),
        for (final r in related)
          MorekiDataRow(
            title: r.questions.isEmpty ? r.id : r.questions.first,
            onTap: () => _askEntry(r),
          ),
      ],
    ];
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _DisclaimerNote extends StatelessWidget {
  const _DisclaimerNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: muted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _QuestionField extends StatelessWidget {
  const _QuestionField({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context);
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: lang.get('coach.hint'),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          tooltip: lang.get('coach.ask'),
          color: AppColors.green,
          onPressed: onSubmit,
          icon: const Icon(Icons.send_rounded),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final foreground =
        selected ? AppColors.darkBackground : AppColors.darkTextPrimary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.green : AppColors.surface2,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.green : AppColors.hairline,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check_rounded, size: 18, color: foreground),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: text.labelLarge?.copyWith(
                        fontSize: 14,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLook {
  const _StatusLook(this.icon, this.color, this.labelKey);

  final IconData icon;
  final Color color;
  final String labelKey;
}

_StatusLook _statusLook(CoachStatus status) {
  switch (status) {
    case CoachStatus.verified:
      return const _StatusLook(
        Icons.verified_rounded,
        AppColors.green,
        'coach.status.verified',
      );
    case CoachStatus.partiallyVerified:
      return const _StatusLook(
        Icons.rule_rounded,
        AppColors.yellow,
        'coach.status.partial',
      );
    case CoachStatus.unverified:
      return const _StatusLook(
        Icons.help_outline_rounded,
        AppColors.orange,
        'coach.status.unverified',
      );
    case CoachStatus.generalGuidance:
      return const _StatusLook(
        Icons.lightbulb_outline_rounded,
        AppColors.cyan,
        'coach.status.general',
      );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.entry,
    required this.data,
    required this.opener,
    required this.openLabel,
    required this.onOpen,
  });

  final CoachEntry entry;
  final CoachData data;
  final String? opener;
  final String? openLabel;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context);
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final look = _statusLook(entry.status);
    final label = lang.get(look.labelKey);
    final verifiedOn = entry.verifiedOn;
    final statusText =
        (verifiedOn != null && entry.status != CoachStatus.generalGuidance)
            ? lang.format('coach.statusOn', {
                'status': label,
                'date': '$verifiedOn',
              })
            : label;

    final paragraphs = entry.answer
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final nextStep = entry.nextStep;
    final sources = <CoachSource>[
      for (final id in entry.sourceIds)
        if (data.sources[id] != null) data.sources[id]!,
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (opener != null) ...[
            Text(
              opener!,
              style: text.bodyMedium?.copyWith(
                color: AppColors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: look.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(look.icon, size: 18, color: look.color),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    statusText,
                    style: text.labelLarge?.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < paragraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            Text(
              paragraphs[i],
              style: text.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
          if (nextStep != null && nextStep.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        lang.get('coach.nextStep').toUpperCase(),
                        style: text.labelMedium?.copyWith(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(nextStep, style: text.bodyLarge),
                ],
              ),
            ),
          ],
          if (openLabel != null && onOpen != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(openLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.darkBackground,
                minimumSize: const Size(0, 48),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              ),
            ),
          ],
          if (sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              lang.get('coach.sources').toUpperCase(),
              style: text.labelMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final s in sources)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  lang.format('coach.sourceRow', {
                    'title': s.title,
                    'date': '${s.checkedOn}',
                  }),
                  style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _NoMatchCard extends StatelessWidget {
  const _NoMatchCard({
    required this.message,
    required this.suggested,
    required this.onPickTopic,
  });

  final String message;
  final List<CoachTopic> suggested;
  final ValueChanged<String> onPickTopic;

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context);
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: text.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: AppSpacing.md),
          if (suggested.isEmpty)
            Text(
              lang.get('coach.pickTopic'),
              style: text.bodyMedium?.copyWith(color: muted),
            )
          else ...[
            Text(
              lang.get('coach.theseTopics'),
              style: text.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final topic in suggested)
                  _TopicChip(
                    label: topic.label,
                    selected: false,
                    onTap: () => onPickTopic(topic.id),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
