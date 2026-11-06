import 'package:flutter/material.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/features/money/domain/daily_spend_calculator.dart';

/// Bar chart of real spending for the last few days (oldest first).
/// The last bar (today) is highlighted. No data means no bars, just a
/// plain message. Nothing here is made up.
class DailySpendChart extends StatelessWidget {
  const DailySpendChart({super.key, required this.days});

  final List<DailySpend> days;

  static const double _barAreaHeight = 120;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = AppLanguage.of(context);

    final maxCents = days.fold<int>(
      0,
      (m, d) => d.spentCents > m ? d.spentCents : m,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.get('chart.title'),
          style: text.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          s.format('chart.lastDays', {'n': '${days.length}'}),
          style: text.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        if (days.isEmpty || maxCents == 0)
          Text(
            s.format('chart.empty', {
              'n': '${days.isEmpty ? 7 : days.length}',
            }),
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          )
        else
          Semantics(
            label: s.format('chart.semantics', {
              'n': '${days.length}',
              'amount': formatRand(days.last.spentCents),
            }),
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < days.length; i++)
                    Expanded(
                      child: _Bar(
                        day: days[i],
                        maxCents: maxCents,
                        highlighted: i == days.length - 1,
                        letter: s.get('chart.wd.${days[i].day.weekday}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.day,
    required this.maxCents,
    required this.highlighted,
    required this.letter,
  });

  final DailySpend day;
  final int maxCents;
  final bool highlighted;
  final String letter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final hasSpend = day.spentCents > 0;
    final fraction = hasSpend ? day.spentCents / maxCents : 0.0;
    final barHeight = hasSpend
        ? (DailySpendChart._barAreaHeight * fraction).clamp(6.0, 120.0)
        : 4.0;

    final barColor = highlighted
        ? AppColors.green
        : AppColors.textMuted.withValues(alpha: hasSpend ? 0.55 : 0.25);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            child: highlighted && hasSpend
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatRand(day.spentCents),
                      style: text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(
            height: DailySpendChart._barAreaHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            letter,
            style: text.bodySmall?.copyWith(
              color: highlighted ? AppColors.green : scheme.onSurfaceVariant,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
