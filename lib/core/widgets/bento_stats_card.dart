import 'package:flutter/material.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/theme/app_theme.dart';

/// One row of the bento card.
class BentoStat {
  const BentoStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.tileColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color tileColor;
}

/// A big dark rounded card holding cream rows: big value, small label,
/// coloured icon tile. Use it for the 3 or 4 most important figures only.
class BentoStatsCard extends StatelessWidget {
  const BentoStatsCard({super.key, required this.stats});

  final List<BentoStat> stats;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            MergeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats[i].value,
                            style: text.headlineSmall?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.creamText,
                              fontFeatures: AppTheme.tabularFigures,
                            ),
                          ),
                          Text(
                            stats[i].label,
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.creamText.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ExcludeSemantics(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: stats[i].tileColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          stats[i].icon,
                          size: 24,
                          color: ThemeData.estimateBrightnessForColor(
                            stats[i].tileColor,
                          ) ==
                              Brightness.light
                              ? AppColors.creamText
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}