import 'package:flutter/material.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/format/money_parts.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/l10n/app_strings.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/bento_stats_card.dart';
import 'package:moreki/core/widgets/hero_number.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/core/widgets/pill_segmented_control.dart';
import 'package:moreki/core/widgets/progress_ring.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/domain/budget_calculator.dart';
import 'package:moreki/features/money/domain/daily_spend_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/money/presentation/daily_spend_chart.dart';
import 'package:moreki/features/profile/application/profile_controller.dart';
import 'package:moreki/features/profile/domain/profile.dart' hide AppLanguage;

/// Home screen (design v2): black canvas, one green glow, hero number,
/// pill switch (Overview | Spending now), score ring, bento stats,
/// daily spending chart, recent activity and one next action.
/// Everything comes from real data.
class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.controller,
    this.onOpenMoney,
    this.profile,
    this.clock,
  });

  final MoneyController controller;

  /// Called by the "next action" button to jump to the Money tab.
  /// If null the button is hidden.
  final VoidCallback? onOpenMoney;

  /// The person's name and payday. If null, Home shows a plain greeting
  /// and no payday line.
  final ProfileController? profile;

  /// Used for the time-of-day greeting. Tests pass their own clock.
  final DateTime Function()? clock;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _view = 0; // 0 = Overview, 1 = Spending now

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final s = AppLanguage.of(context);

    return AccentGlow(
      color: AppColors.green,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            widget.controller,
            if (profile != null) profile,
          ]),
          builder: (context, _) {
            final c = widget.controller;
            final summary = c.summary;
            final score = c.score;
            final now = (widget.clock ?? DateTime.now)();
            final dailyDays = DailySpendCalculator.lastDays(
              expenses: c.expenses,
              today: now,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                _TopBar(
                  greeting: _greetingFor(s, now.hour),
                  name: profile?.settings.displayName ?? '',
                  payday: profile?.payday,
                ),
                const SizedBox(height: 24),
                _Hero(summary: summary),
                const SizedBox(height: 24),
                PillSegmentedControl(
                  labels: [
                    s.get('home.view.overview'),
                    s.get('home.view.spending'),
                  ],
                  selectedIndex: _view,
                  onChanged: (i) => setState(() => _view = i),
                  accent: AppColors.green,
                ),
                const SizedBox(height: 24),
                if (_view == 0) ...[
                  _ScoreSection(score: score, summary: summary),
                  const SizedBox(height: 24),
                  BentoStatsCard(
                    stats: [
                      BentoStat(
                        value: formatRand(summary.spentCents),
                        label: s.get('home.bento.spent'),
                        icon: Icons.receipt_long_rounded,
                        tileColor: AppColors.yellow,
                      ),
                      BentoStat(
                        value: summary.budgetCents > 0
                            ? formatRand(summary.budgetCents)
                            : s.get('home.notSet'),
                        label: s.get('home.bento.budget'),
                        icon: Icons.flag_rounded,
                        tileColor: AppColors.green,
                      ),
                      BentoStat(
                        value: '${c.expenses.length}',
                        label: s.get('home.bento.logged'),
                        icon: Icons.edit_note_rounded,
                        tileColor: AppColors.violet,
                      ),
                    ],
                  ),
                ] else
                  _SpendingNow(summary: summary),
                const SizedBox(height: 32),
                DailySpendChart(days: dailyDays),
                const SizedBox(height: 32),
                _RecentActivity(expenses: c.expenses),
                const SizedBox(height: 24),
                _NextAction(
                  summary: summary,
                  score: score,
                  onTap: widget.onOpenMoney,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- top bar

String _greetingFor(AppStrings s, int hour) {
  if (hour < 12) return s.get('home.greeting.morning');
  if (hour < 18) return s.get('home.greeting.afternoon');
  return s.get('home.greeting.evening');
}

String _paydayText(AppStrings s, int daysAway) {
  if (daysAway <= 0) return s.get('home.payday.today');
  if (daysAway == 1) return s.get('home.payday.tomorrow');
  return s.format('home.payday.days', {'n': '$daysAway'});
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.greeting,
    required this.name,
    required this.payday,
  });

  final String greeting;
  final String name;

  /// Null when the person has not set a payday.
  final PaydayInfo? payday;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = AppLanguage.of(context);
    final hello = name.trim().isEmpty ? greeting : '$greeting, ${name.trim()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'moreki',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hello,
          style: text.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
        if (payday != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: AppColors.green,
              ),
              const SizedBox(width: 6),
              Text(
                _paydayText(s, payday!.daysAway),
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------------- hero

class _Hero extends StatelessWidget {
  const _Hero({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = AppLanguage.of(context);

    if (summary.budgetCents <= 0) {
      final parts = splitRandForDisplay(formatRand(0));
      return HeroNumber(
        value: parts.whole,
        unit: parts.cents,
        label: s.get('home.hero.label'),
        caption: s.get('home.hero.noBudget'),
      );
    }

    final used = (summary.usedFraction * 100).round();
    final values = {
      'used': '$used',
      'budget': formatRand(summary.budgetCents),
    };
    final caption = summary.isOverBudget
        ? s.format('home.hero.over', values)
        : s.format('home.hero.used', values);
    final parts = splitRandForDisplay(formatRand(summary.remainingCents));

    return HeroNumber(
      value: parts.whole,
      unit: parts.cents,
      label: s.get('home.hero.label'),
      caption: caption,
      valueColor: summary.isOverBudget ? AppColors.red : null,
    );
  }
}

// ------------------------------------------------------------ score section

class _ScoreSection extends StatelessWidget {
  const _ScoreSection({required this.score, required this.summary});

  final int? score;
  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = AppLanguage.of(context);
    final unlocked = score != null;

    // Real numbers only. "Biggest spend" is the top category this month.
    final budgetUsed = summary.budgetCents > 0
        ? '${(summary.usedFraction * 100).round()}%'
        : s.get('home.notSet');
    ExpenseCategory? topCategory;
    var topCents = 0;
    summary.byCategory.forEach((category, cents) {
      if (cents > topCents) {
        topCents = cents;
        topCategory = category;
      }
    });
    final biggest = topCategory == null
        ? s.get('home.nothingYet')
        : _categoryLabel(s, topCategory!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProgressRing(
              value: unlocked ? score! / 100 : 0,
              semanticsLabel: unlocked
                  ? s.format('home.score.semUnlocked', {'score': '$score'})
                  : s.get('home.score.semLocked'),
              size: 150,
              strokeWidth: 14,
              showTicks: true,
              colors: const [
                AppColors.blue,
                AppColors.cyan,
                AppColors.green,
                AppColors.yellow,
              ],
              center: unlocked
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.get('home.score.of'),
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      Icons.lock_outline_rounded,
                      color: scheme.onSurfaceVariant,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RingStat(
                    label: s.get('home.stat.score'),
                    value: unlocked
                        ? '$score / 100'
                        : s.get('home.score.locked'),
                  ),
                  const SizedBox(height: 14),
                  _RingStat(
                    label: s.get('home.stat.budgetUsed'),
                    value: budgetUsed,
                  ),
                  const SizedBox(height: 14),
                  _RingStat(
                    label: s.get('home.stat.biggest'),
                    value: biggest,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!unlocked) ...[
          const SizedBox(height: 16),
          Text(
            s.get('home.score.unlockHint'),
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          s.get('home.score.explanation'),
          style: text.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _RingStat extends StatelessWidget {
  const _RingStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------- spending now

class _SpendingNow extends StatelessWidget {
  const _SpendingNow({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = AppLanguage.of(context);

    final entries = summary.byCategory.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Text(
        s.get('home.spending.empty'),
        style: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.4,
        ),
      );
    }

    final total = summary.spentCents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.get('home.spending.title'),
          style: text.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < entries.length; i++)
          MorekiDataRow(
            title: _categoryLabel(s, entries[i].key),
            subtitle: s.format('home.spending.pct', {
              'n': '${(entries[i].value * 100 / total).round()}',
            }),
            value: formatRand(entries[i].value),
            indicatorColor: _categoryColor(entries[i].key),
            showDivider: i != entries.length - 1,
          ),
      ],
    );
  }
}

// --------------------------------------------------------- recent activity

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = AppLanguage.of(context);

    final recent = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    final shown = recent.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.get('home.recent.title'),
          style: text.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          Text(
            s.get('home.recent.empty'),
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          )
        else
          for (var i = 0; i < shown.length; i++)
            MorekiDataRow(
              title: _categoryLabel(s, shown[i].category),
              subtitle: shown[i].note.isEmpty
                  ? _shortDate(s, shown[i].date)
                  : '${_shortDate(s, shown[i].date)} \u00B7 ${shown[i].note}',
              value: formatRand(shown[i].amountCents),
              indicatorColor: _categoryColor(shown[i].category),
              showDivider: i != shown.length - 1,
            ),
      ],
    );
  }
}

// -------------------------------------------------------------- next action

class _NextAction extends StatelessWidget {
  const _NextAction({
    required this.summary,
    required this.score,
    required this.onTap,
  });

  final BudgetSummary summary;
  final int? score;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = AppLanguage.of(context);

    final String title;
    final String body;
    final String button;
    final IconData icon;

    if (summary.budgetCents <= 0) {
      title = s.get('home.next.setBudget.title');
      body = s.get('home.next.setBudget.body');
      button = s.get('home.next.setBudget.button');
      icon = Icons.flag_rounded;
    } else if (summary.isOverBudget) {
      title = s.format('home.next.over.title', {
        'amount': formatRand(-summary.remainingCents),
      });
      body = s.get('home.next.over.body');
      button = s.get('home.next.over.button');
      icon = Icons.info_outline_rounded;
    } else if (summary.usedFraction >= 0.8) {
      title = s.format('home.next.high.title', {
        'n': '${(summary.usedFraction * 100).round()}',
      });
      body = s.get('home.next.high.body');
      button = s.get('home.next.high.button');
      icon = Icons.info_outline_rounded;
    } else if (score == null) {
      title = s.get('home.next.log.title');
      body = s.get('home.next.log.body');
      button = s.get('home.next.log.button');
      icon = Icons.edit_note_rounded;
    } else {
      title = s.get('home.next.ok.title');
      body = s.get('home.next.ok.body');
      button = s.get('home.next.ok.button');
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onTap, child: Text(button)),
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- helpers

String _categoryLabel(AppStrings s, ExpenseCategory c) {
  switch (c) {
    case ExpenseCategory.food:
      return s.get('category.food');
    case ExpenseCategory.transport:
      return s.get('category.transport');
    case ExpenseCategory.rent:
      return s.get('category.rent');
    case ExpenseCategory.airtimeData:
      return s.get('category.airtimeData');
    case ExpenseCategory.electricity:
      return s.get('category.electricity');
    case ExpenseCategory.family:
      return s.get('category.family');
    case ExpenseCategory.entertainment:
      return s.get('category.entertainment');
    case ExpenseCategory.other:
      return s.get('category.other');
  }
}

Color _categoryColor(ExpenseCategory c) {
  switch (c) {
    case ExpenseCategory.food:
      return AppColors.orange;
    case ExpenseCategory.transport:
      return AppColors.cyan;
    case ExpenseCategory.rent:
      return AppColors.violet;
    case ExpenseCategory.airtimeData:
      return AppColors.blue;
    case ExpenseCategory.electricity:
      return AppColors.yellow;
    case ExpenseCategory.family:
      return AppColors.green;
    case ExpenseCategory.entertainment:
      return AppColors.red;
    case ExpenseCategory.other:
      return AppColors.textMuted;
  }
}

String _shortDate(AppStrings s, DateTime d) => '${d.day} ${s.month(d.month)}';
