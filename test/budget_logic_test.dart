import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/domain/budget_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';

Expense _expense(int cents, ExpenseCategory category, DateTime date) => Expense(
  id: '${date.microsecondsSinceEpoch}-$cents',
  amountCents: cents,
  category: category,
  date: date,
);

void main() {
  group('BudgetCalculator', () {
    test('only counts expenses from the chosen month', () {
      final summary = BudgetCalculator.summarise(
        expenses: [
          _expense(10000, ExpenseCategory.food, DateTime(2026, 11, 5)),
          _expense(99999, ExpenseCategory.food, DateTime(2026, 10, 30)),
        ],
        budgetCents: 100000,
        month: DateTime(2026, 11, 15),
      );
      expect(summary.spentCents, 10000);
    });

    test('groups spending by category', () {
      final summary = BudgetCalculator.summarise(
        expenses: [
          _expense(1000, ExpenseCategory.food, DateTime(2026, 11, 1)),
          _expense(2000, ExpenseCategory.food, DateTime(2026, 11, 2)),
          _expense(500, ExpenseCategory.transport, DateTime(2026, 11, 3)),
        ],
        budgetCents: 100000,
        month: DateTime(2026, 11, 15),
      );
      expect(summary.byCategory[ExpenseCategory.food], 3000);
      expect(summary.byCategory[ExpenseCategory.transport], 500);
    });

    test('over budget gives negative remaining', () {
      final summary = BudgetCalculator.summarise(
        expenses: [
          _expense(150000, ExpenseCategory.rent, DateTime(2026, 11, 1)),
        ],
        budgetCents: 100000,
        month: DateTime(2026, 11, 15),
      );
      expect(summary.remainingCents, -50000);
      expect(summary.isOverBudget, isTrue);
    });

    test('usedFraction is 0 when no budget is set', () {
      final summary = BudgetCalculator.summarise(
        expenses: [
          _expense(1000, ExpenseCategory.food, DateTime(2026, 11, 1)),
        ],
        budgetCents: 0,
        month: DateTime(2026, 11, 15),
      );
      expect(summary.usedFraction, 0);
    });
  });
}