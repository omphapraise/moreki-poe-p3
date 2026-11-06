import 'package:flutter/material.dart';
import 'package:moreki/core/theme/app_spacing.dart';

/// A big headline figure with a small unit and a quiet label.
/// The caller formats the money, e.g. value "R 4 750", unit ".00".
/// Negative values: pass "-R 120" as the value.
class HeroNumber extends StatelessWidget {
  const HeroNumber({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.caption,
    this.valueColor,
  });

  final String value;
  final String? unit;
  final String label;
  final String? caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Semantics(
      container: true,
      label: '$label: $value${unit ?? ''}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: text.labelMedium?.copyWith(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: text.displayLarge?.copyWith(
                      fontSize: 64,
                      color: valueColor,
                    ),
                  ),
                  if (unit != null)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Text(
                        unit!,
                        style: text.titleLarge?.copyWith(color: muted),
                      ),
                    ),
                ],
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                caption!,
                style: text.bodyMedium?.copyWith(
                  color: muted,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}