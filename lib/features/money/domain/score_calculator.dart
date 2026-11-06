import 'package:moreki/features/money/domain/budget_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';

/// The Moreki Score (0-100). Explainable on purpose, and NOT a credit score.
///
/// Locked (null) until a budget is set AND there are at least
/// [minExpenses] expenses on at least [minDays] different days this month.
///
/// Score = Pace (0-80) + Tracking (0-20):
/// - Pace: compares how much of the budget you've used with how much of the
///   month has passed. On or under pace = 80. At twice the pace or worse = 0.
///   In between it slides down in a straight line.
/// - Tracking: days with at least one expense, out of the days so far this
///   month (counted over at most the first 7 days).
/// If you are over budget, the total is capped at [overBudgetCap].
class ScoreCalculator {
  const ScoreCalculator._();

  static const int minExpenses = 3;
  static const int minDays = 2;
  static const int maxPaceScore = 80;
  static const int maxTrackingScore = 20;
  static const int overBudgetCap = 40;
  static const int trackingWindowDays = 7;

  /// Shown under the ring. Will move to the translation files later.
  static const String explanation =
      "Your score shows how your spending is pacing against your budget "
      "and how consistently you track it. It's not a credit score.";

  static int? calculate({
    required BudgetSummary summary,
    required List<Expense> expenses,
    required DateTime today,
  }) {
    if (summary.budgetCents <= 0) return null;

    final thisMonth = expenses
        .where((e) => e.date.year == today.year && e.date.month == today.month)
        .toList();
    final daysWithExpenses = thisMonth.map((e) => e.date.day).toSet();

    if (thisMonth.length < minExpenses || daysWithExpenses.length < minDays) {
      return null;
    }

    // Pace
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final monthFraction = today.day / daysInMonth;
    final ratio = summary.usedFraction / monthFraction;
    final double pace;
    if (ratio <= 1) {
      pace = maxPaceScore.toDouble();
    } else if (ratio >= 2) {
      pace = 0;
    } else {
      pace = maxPaceScore * (2 - ratio);
    }

    // Tracking
    final window = today.day < trackingWindowDays ? today.day : trackingWindowDays;
    final tracked =
    daysWithExpenses.length < window ? daysWithExpenses.length : window;
    final tracking = maxTrackingScore * tracked / window;

    var total = pace + tracking;
    if (summary.isOverBudget && total > overBudgetCap) {
      total = overBudgetCap.toDouble();
    }
    return total.round().clamp(0, 100).toInt();
  }
}