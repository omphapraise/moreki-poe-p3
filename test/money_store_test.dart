import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads the budget and expenses', () async {
    final store = SharedPrefsMoneyStore();
    final date = DateTime(2026, 10, 24, 14, 30);

    await store.save(MoneyData(
      budgetCents: 500000,
      expenses: [
        Expense(
          id: '1',
          amountCents: 12550,
          category: ExpenseCategory.electricity,
          date: date,
          note: 'prepaid',
        ),
      ],
    ));

    final loaded = await store.load();
    expect(loaded.budgetCents, 500000);
    expect(loaded.expenses, hasLength(1));
    expect(loaded.expenses.first.amountCents, 12550);
    expect(loaded.expenses.first.category, ExpenseCategory.electricity);
    expect(loaded.expenses.first.date, date);
    expect(loaded.expenses.first.note, 'prepaid');
  });

  test('loads empty data when nothing was saved', () async {
    final loaded = await SharedPrefsMoneyStore().load();

    expect(loaded.budgetCents, 0);
    expect(loaded.expenses, isEmpty);
  });

  test('loads empty data instead of crashing when saved data is damaged',
          () async {
        SharedPreferences.setMockInitialValues({'moreki_money_v1': 'not json'});

        final loaded = await SharedPrefsMoneyStore().load();

        expect(loaded.budgetCents, 0);
        expect(loaded.expenses, isEmpty);
      });

  test('a new controller picks up what the old one saved', () async {
    final store = SharedPrefsMoneyStore();

    final first = MoneyController(store: store);
    await first.setBudgetCents(100000);
    await first.addExpense(
        amountCents: 2500, category: ExpenseCategory.transport);

    final second = MoneyController(store: store);
    await second.load();

    expect(second.budgetCents, 100000);
    expect(second.expenses, hasLength(1));
    expect(second.expenses.first.amountCents, 2500);
    expect(second.summary.spentCents, 2500);
  });
}