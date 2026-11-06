import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/domain/budget_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/money/domain/score_calculator.dart';
import 'package:moreki/features/widget/domain/widget_snapshot.dart';

Expense _expense(int cents, DateTime date) => Expense(
  id: '${date.microsecondsSinceEpoch}-$cents',
  amountCents: cents,
  category: ExpenseCategory.food,
  date: date,
);

void main() {
  final now = DateTime(2026, 10, 29, 14, 5);

  test('with no budget it says Not set and the score is locked', () {
    final s = WidgetSnapshot.fromMoney(
      budgetCents: 0,
      expenses: const [],
      now: now,
    );
    expect(s.leftValue, 'Not set');
    expect(s.leftCaption, 'Open Moreki to set your budget');
    expect(s.isOverBudget, isFalse);
    expect(s.scoreValue, 'Locked');
    expect(s.scoreLocked, isTrue);
  });

  test('shows what is left and how much of the budget is used', () {
    final s = WidgetSnapshot.fromMoney(
      budgetCents: 100000,
      expenses: [_expense(25000, DateTime(2026, 10, 28))],
      now: now,
    );
    expect(s.leftValue, 'R 750.00');
    expect(s.leftCaption, '25% of R 1 000.00 used');
    expect(s.isOverBudget, isFalse);
    expect(s.scoreLocked, isTrue);
  });

  test('over budget shows a minus sign and says so in words', () {
    final s = WidgetSnapshot.fromMoney(
      budgetCents: 100000,
      expenses: [_expense(120000, DateTime(2026, 10, 28))],
      now: now,
    );
    expect(s.leftValue, '-R 200.00');
    expect(s.leftCaption, 'Over budget this month');
    expect(s.isOverBudget, isTrue);
  });

  test('expenses from other months are ignored', () {
    final s = WidgetSnapshot.fromMoney(
      budgetCents: 100000,
      expenses: [_expense(50000, DateTime(2026, 9, 30))],
      now: now,
    );
    expect(s.leftValue, 'R 1 000.00');
    expect(s.leftCaption, '0% of R 1 000.00 used');
  });

  test('the score matches the real score rule when it is unlocked', () {
    final expenses = [
      _expense(1000, DateTime(2026, 10, 27)),
      _expense(1000, DateTime(2026, 10, 28)),
      _expense(1000, DateTime(2026, 10, 29)),
    ];
    final summary = BudgetCalculator.summarise(
      expenses: expenses,
      budgetCents: 100000,
      month: now,
    );
    final expected = ScoreCalculator.calculate(
      summary: summary,
      expenses: expenses,
      today: now,
    );
    final s = WidgetSnapshot.fromMoney(
      budgetCents: 100000,
      expenses: expenses,
      now: now,
    );
    expect(expected, isNotNull);
    expect(s.scoreLocked, isFalse);
    expect(s.scoreValue, '$expected');
    expect(s.scoreCaption, '/ 100');
  });

  test('says when the numbers were last updated', () {
    final s = WidgetSnapshot.fromMoney(
      budgetCents: 0,
      expenses: const [],
      now: DateTime(2026, 10, 9, 7, 3),
    );
    expect(s.asOf, 'As of 9 Oct, 07:03');
  });

  test('hands the Android widget every value it reads', () {
    final map = WidgetSnapshot.fromMoney(
      budgetCents: 0,
      expenses: const [],
      now: now,
    ).toMap();
    expect(
      map.keys,
      containsAll(<String>[
        'left_label',
        'left_value',
        'left_caption',
        'over_budget',
        'score_label',
        'score_value',
        'score_caption',
        'score_locked',
        'as_of',
      ]),
    );
  });
}