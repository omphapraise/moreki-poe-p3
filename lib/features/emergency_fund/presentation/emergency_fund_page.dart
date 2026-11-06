import 'package:flutter/material.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/l10n/app_strings.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/hero_number.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/core/widgets/pill_segmented_control.dart';
import 'package:moreki/core/widgets/progress_ring.dart';
import 'package:moreki/features/emergency_fund/application/emergency_fund_controller.dart';
import 'package:moreki/features/emergency_fund/domain/emergency_fund.dart';

String _shortDate(AppStrings s, DateTime d) => '${d.day} ${s.month(d.month)}';

String _monthYear(AppStrings s, DateTime d) => '${s.month(d.month)} ${d.year}';

String _monthsLabel(AppStrings s, int n) => n == 1
    ? s.get('ef.month.one')
    : s.format('ef.month.many', {'n': '$n'});

/// 25000 cents -> "250", 1250 cents -> "12.50", 0 -> "".
String _centsToInput(int cents) {
  if (cents <= 0) return '';
  final rands = cents ~/ 100;
  final rest = cents % 100;
  return rest == 0 ? '$rands' : '$rands.${rest.toString().padLeft(2, '0')}';
}

String _milestoneTitle(AppStrings s, int months) {
  switch (months) {
    case 0:
      return s.get('ef.ms.week');
    case 1:
      return s.get('ef.ms.month');
    case 3:
      return s.get('ef.ms.three');
    case 6:
      return s.get('ef.ms.six');
  }
  return s.format('ef.ms.other', {'months': _monthsLabel(s, months)});
}

/// The Emergency Fund Builder screen.
class EmergencyFundPage extends StatefulWidget {
  const EmergencyFundPage({super.key, required this.controller});

  final EmergencyFundController controller;

  @override
  State<EmergencyFundPage> createState() => _EmergencyFundPageState();
}

class _EmergencyFundPageState extends State<EmergencyFundPage> {
  final TextEditingController _essentials = TextEditingController();
  final TextEditingController _monthly = TextEditingController();
  final TextEditingController _deposit = TextEditingController();

  // Errors are kept as flags and turned into text when drawn, so they
  // follow the chosen language. Essentials: 0 none, 1 invalid, 2 zero.
  int _essentialsError = 0;
  bool _monthlyBad = false;
  bool _depositBad = false;

  @override
  void initState() {
    super.initState();
    final plan = widget.controller.plan;
    _essentials.text = _centsToInput(plan.essentialsCents);
    _monthly.text = _centsToInput(plan.monthlyContributionCents);
  }

  @override
  void dispose() {
    _essentials.dispose();
    _monthly.dispose();
    _deposit.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    FocusScope.of(context).unfocus();
    final essentials = parseRandToCents(_essentials.text);
    final monthlyText = _monthly.text.trim();
    final monthly = monthlyText.isEmpty ? 0 : parseRandToCents(monthlyText);

    var essentialsError = 0;
    if (essentials == null) {
      essentialsError = 1;
    } else if (essentials == 0) {
      essentialsError = 2;
    }

    setState(() {
      _essentialsError = essentialsError;
      _monthlyBad = monthly == null;
    });
    if (essentials == null || essentials == 0 || monthly == null) return;

    await widget.controller.savePlan(
      essentialsCents: essentials,
      monthlyContributionCents: monthly,
    );
  }

  Future<void> _addDeposit() async {
    FocusScope.of(context).unfocus();
    final cents = parseRandToCents(_deposit.text);
    if (cents == null || cents <= 0) {
      setState(() => _depositBad = true);
      return;
    }
    setState(() => _depositBad = false);
    final added = await widget.controller.addDeposit(amountCents: cents);
    if (added) _deposit.clear();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = AppLanguage.of(context);

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
                      tooltip: s.get('ef.back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          s.get('ef.title'),
                          style: text.headlineMedium,
                        ),
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
    final c = widget.controller;
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final s = AppLanguage.of(context);
    final plan = c.plan;
    final progress = c.progress;
    final hasGoal = progress.targetCents > 0;
    final percent = (progress.fraction * 100).floor();
    final targetIndex =
        EmergencyFundCalculator.targetOptions.indexOf(plan.targetMonths);
    final recent = c.deposits.reversed.take(5).toList();

    String? essentialsText;
    if (_essentialsError == 1) essentialsText = s.get('ef.badAmount');
    if (_essentialsError == 2) essentialsText = s.get('ef.essentialsZero');

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          s.get('ef.intro'),
          style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        HeroNumber(
          label: s.get('ef.saved'),
          value: formatRand(progress.savedCents),
          caption: hasGoal
              ? s.format('ef.goalCaption', {
                  'goal': formatRand(progress.targetCents),
                  'months': _monthsLabel(s, plan.targetMonths),
                })
              : s.get('ef.noGoalCaption'),
        ),
        if (hasGoal) ...[
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              ProgressRing(
                value: progress.fraction,
                size: 96,
                strokeWidth: 10,
                colors: const [AppColors.cyan, AppColors.green],
                semanticsLabel: s.format(
                  'ef.ringSemantics',
                  {'percent': '$percent'},
                ),
                center: Text('$percent%', style: text.titleLarge),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.isComplete
                          ? s.get('ef.goalReached')
                          : s.format('ef.toGo', {
                              'amount': formatRand(progress.remainingCents),
                            }),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _estimateText(s, progress, plan),
                      style: text.bodyMedium?.copyWith(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(s.get('ef.milestones'), style: text.titleMedium),
          for (var i = 0; i < progress.milestones.length; i++)
            MorekiDataRow(
              title: _milestoneTitle(s, progress.milestones[i].months),
              subtitle: progress.milestones[i].reached
                  ? s.get('ef.reached')
                  : s.get('ef.toGoShort'),
              value: formatRand(progress.milestones[i].targetCents),
              indicatorColor: progress.milestones[i].reached
                  ? AppColors.green
                  : AppColors.textMuted,
              showDivider: i < progress.milestones.length - 1,
            ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _Panel(
          title: s.get('ef.add.title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AmountField(
                key: const Key('fundDepositField'),
                controller: _deposit,
                label: s.get('ef.add.field'),
                errorText: _depositBad ? s.get('ef.badAmount') : null,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('addDepositButton'),
                  onPressed: _addDeposit,
                  child: Text(s.get('ef.add.button')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Panel(
          title: s.get('ef.plan.title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AmountField(
                key: const Key('fundEssentialsField'),
                controller: _essentials,
                label: s.get('ef.plan.essentials'),
                errorText: essentialsText,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(s.get('ef.plan.goal'), style: text.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              PillSegmentedControl(
                labels: [
                  for (final m in EmergencyFundCalculator.targetOptions)
                    _monthsLabel(s, m),
                ],
                selectedIndex: targetIndex < 0 ? 1 : targetIndex,
                accent: AppColors.green,
                onChanged: (i) => c.setTargetMonths(
                  EmergencyFundCalculator.targetOptions[i],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AmountField(
                key: const Key('fundMonthlyField'),
                controller: _monthly,
                label: s.get('ef.plan.monthly'),
                errorText: _monthlyBad ? s.get('ef.badAmount') : null,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('savePlanButton'),
                  onPressed: _savePlan,
                  child: Text(s.get('ef.plan.save')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(s.get('ef.recent.title'), style: text.titleMedium),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              s.get('ef.recent.empty'),
              style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
            ),
          )
        else
          for (var i = 0; i < recent.length; i++)
            MorekiDataRow(
              title: s.get('ef.recent.row'),
              subtitle: _shortDate(s, recent[i].date),
              value: formatRand(recent[i].amountCents),
              valueColor: AppColors.green,
              showDivider: i < recent.length - 1,
            ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          s.get('ef.rule'),
          style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  String _estimateText(
    AppStrings s,
    FundProgress progress,
    EmergencyFundPlan plan,
  ) {
    if (progress.isComplete) return s.get('ef.est.done');
    if (plan.monthlyContributionCents <= 0) return s.get('ef.est.none');
    final months = progress.monthsToGoal ?? 0;
    final finish = progress.estimatedFinish;
    final when = finish == null
        ? ''
        : ' ${s.format('ef.est.around', {'date': _monthYear(s, finish)})}';
    return s.format('ef.est.text', {
      'amount': formatRand(plan.monthlyContributionCents),
      'months': _monthsLabel(s, months),
      'when': when,
    });
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixText: 'R ',
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
      ),
    );
  }
}
