import 'package:moreki/features/money/domain/expense.dart';

/// The totals for one month against one budget.
class BudgetSummary {
  const BudgetSummary({
    required this.budgetCents,
    required this.spentCents,
    required this.byCategory,
  });

  final int budgetCents;
  final int spentCents;
  final Map<ExpenseCategory, int> byCategory;

  int get remainingCents => budgetCents - spentCents;

  bool get isOverBudget => spentCents > budgetCents;

  /// 0.0 = nothing spent, 1.0 = whole budget spent. Zero if no budget is set.
  double get usedFraction => budgetCents <= 0 ? 0 : spentCents / budgetCents;
}

class BudgetCalculator {
  const BudgetCalculator._();

  /// Adds up the expenses that fall in the same year and month as [month].
  static BudgetSummary summarise({
    required List<Expense> expenses,
    required int budgetCents,
    required DateTime month,
  }) {
    final byCategory = <ExpenseCategory, int>{};
    var spent = 0;

    for (final e in expenses) {
      final inMonth = e.date.year == month.year && e.date.month == month.month;
      if (!inMonth) continue;
      spent += e.amountCents;
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amountCents;
    }

    return BudgetSummary(
      budgetCents: budgetCents,
      spentCents: spent,
      byCategory: byCategory,
    );
  }
}