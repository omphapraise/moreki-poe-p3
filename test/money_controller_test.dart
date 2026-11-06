import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/domain/expense.dart';

void main() {
  test('starts empty with no score', () {
    final controller = MoneyController();

    expect(controller.expenses, isEmpty);
    expect(controller.budgetCents, 0);
    expect(controller.score, isNull);
  });

  test('adding expenses updates totals; score stays locked until enough data',
          () async {
        final controller = MoneyController(budgetCents: 100000);

        await controller.addExpense(
            amountCents: 50000, category: ExpenseCategory.food);
        expect(controller.summary.spentCents, 50000);
        expect(controller.score, isNull);

        await controller.addExpense(
            amountCents: 50000, category: ExpenseCategory.rent);
        expect(controller.summary.spentCents, 100000);
        // Only 2 expenses so far: the score needs at least 3 on 2 different days.
        expect(controller.score, isNull);
      });

  test('ignores expenses of zero or less', () {
    final controller = MoneyController(budgetCents: 100000);

    controller.addExpense(amountCents: 0, category: ExpenseCategory.food);
    controller.addExpense(amountCents: -100, category: ExpenseCategory.food);

    expect(controller.expenses, isEmpty);
  });

  test('notifies listeners when something changes', () {
    final controller = MoneyController();
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.setBudgetCents(100000);
    controller.addExpense(
        amountCents: 1000, category: ExpenseCategory.transport);

    expect(notifications, 2);
  });
}