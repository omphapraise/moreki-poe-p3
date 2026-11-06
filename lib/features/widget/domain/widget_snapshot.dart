import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/features/money/domain/budget_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/money/domain/score_calculator.dart';

/// Everything the Android home-screen widget shows, already turned into
/// text. The widget only displays this; all the maths happens here, in
/// tested Dart code, using the same rules as the Home screen.
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.leftLabel,
    required this.leftValue,
    required this.leftCaption,
    required this.isOverBudget,
    required this.scoreLabel,
    required this.scoreValue,
    required this.scoreCaption,
    required this.scoreLocked,
    required this.asOf,
  });

  factory WidgetSnapshot.fromMoney({
    required int budgetCents,
    required List<Expense> expenses,
    required DateTime now,
  }) {
    final summary = BudgetCalculator.summarise(
      expenses: expenses,
      budgetCents: budgetCents,
      month: now,
    );
    final score = ScoreCalculator.calculate(
      summary: summary,
      expenses: expenses,
      today: now,
    );

    final String leftValue;
    final String leftCaption;
    if (budgetCents <= 0) {
      leftValue = 'Not set';
      leftCaption = 'Open Moreki to set your budget';
    } else {
      leftValue = formatRand(summary.remainingCents);
      if (summary.isOverBudget) {
        leftCaption = 'Over budget this month';
      } else {
        final used = (summary.usedFraction * 100).round();
        leftCaption = '$used% of ${formatRand(budgetCents)} used';
      }
    }

    return WidgetSnapshot(
      leftLabel: 'LEFT TO SPEND',
      leftValue: leftValue,
      leftCaption: leftCaption,
      isOverBudget: budgetCents > 0 && summary.isOverBudget,
      scoreLabel: 'MOREKI SCORE',
      scoreValue: score == null ? 'Locked' : '$score',
      scoreCaption: score == null ? '' : '/ 100',
      scoreLocked: score == null,
      asOf: 'As of ${now.day} ${_months[now.month - 1]}, '
          '${_two(now.hour)}:${_two(now.minute)}',
    );
  }

  final String leftLabel;
  final String leftValue;
  final String leftCaption;
  final bool isOverBudget;
  final String scoreLabel;
  final String scoreValue;
  final String scoreCaption;
  final bool scoreLocked;
  final String asOf;

  /// The values handed to the Android widget (it reads these by key).
  Map<String, String> toMap() => {
    'left_label': leftLabel,
    'left_value': leftValue,
    'left_caption': leftCaption,
    'over_budget': isOverBudget ? '1' : '0',
    'score_label': scoreLabel,
    'score_value': scoreValue,
    'score_caption': scoreCaption,
    'score_locked': scoreLocked ? '1' : '0',
    'as_of': asOf,
  };

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');
}