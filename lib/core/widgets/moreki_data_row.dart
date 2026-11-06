import 'package:flutter/material.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/theme/app_theme.dart';

/// An unboxed list row: title, small subtitle, big value on the right.
/// Used for transactions and other lists. Shows a chevron if [onTap] is set.
class MorekiDataRow extends StatelessWidget {
  const MorekiDataRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.valueColor,
    this.indicatorColor,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final Color? valueColor;
  final Color? indicatorColor;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          if (indicatorColor != null) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: text.bodySmall?.copyWith(color: muted)),
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: text.titleMedium?.copyWith(
                color: valueColor,
                fontFeatures: AppTheme.tabularFigures,
              ),
            ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ],
      ),
    );

    return MergeSemantics(
      child: Column(
        children: [
          onTap == null ? row : InkWell(onTap: onTap, child: row),
          if (showDivider)
            const Divider(height: 1, thickness: 1, color: AppColors.hairline),
        ],
      ),
    );
  }
}