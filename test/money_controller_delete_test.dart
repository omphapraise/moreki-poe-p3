import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MoneyController> _seeded({MoneyStore? store}) async {
  final c = MoneyController(store: store);
  await c.setBudgetCents(1000000);
  await c.addExpense(amountCents: 10000, category: ExpenseCategory.food);
  await c.addExpense(amountCents: 20000, category: ExpenseCategory.transport);
  await c.addExpense(amountCents: 30000, category: ExpenseCategory.rent);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every expense gets its own id, even when added back to back',
          () async {
        final c = await _seeded();
        expect(c.expenses.map((e) => e.id).toSet().length, 3);
      });

  test('removing an expense takes it out of the list and the totals',
          () async {
        final c = await _seeded();
        final id = c.expenses[1].id; // the transport expense
        final removed = await c.removeExpense(id);

        expect(removed, isNotNull);
        expect(c.expenses.length, 2);
        expect(c.summary.spentCents, 40000);
        expect(c.summary.remainingCents, 960000);
      });

  test('remove tells you what was removed and where it was', () async {
    final c = await _seeded();
    final removed = await c.removeExpense(c.expenses[1].id);

    expect(removed!.index, 1);
    expect(removed.expense.category, ExpenseCategory.transport);
    expect(removed.expense.amountCents, 20000);
  });

  test('removing an unknown id does nothing and tells nobody', () async {
    final c = await _seeded();
    var calls = 0;
    c.addListener(() => calls++);

    expect(await c.removeExpense('nope'), isNull);
    expect(c.expenses.length, 3);
    expect(calls, 0);
  });

  test('restore puts the expense back where it was', () async {
    final c = await _seeded();
    final removed = await c.removeExpense(c.expenses[1].id);
    await c.restoreExpense(removed!);

    expect(
      c.expenses.map((e) => e.category).toList(),
      [
        ExpenseCategory.food,
        ExpenseCategory.transport,
        ExpenseCategory.rent,
      ],
    );
  });

  test('pressing undo twice does not duplicate the expense', () async {
    final c = await _seeded();
    final removed = await c.removeExpense(c.expenses[1].id);
    await c.restoreExpense(removed!);
    await c.restoreExpense(removed);

    expect(c.expenses.length, 3);
  });

  test('restore copes with an index past the end of the list', () async {
    final c = MoneyController();
    await c.addExpense(amountCents: 100, category: ExpenseCategory.food);
    final extra = Expense(
      id: 'x',
      amountCents: 200,
      category: ExpenseCategory.rent,
      date: DateTime.now(),
    );

    await c.restoreExpense(RemovedExpense(expense: extra, index: 99));

    expect(c.expenses.length, 2);
    expect(c.expenses.last.id, 'x');
  });

  test('remove and restore each tell listeners once', () async {
    final c = await _seeded();
    var calls = 0;
    c.addListener(() => calls++);

    final removed = await c.removeExpense(c.expenses[0].id);
    expect(calls, 1);
    await c.restoreExpense(removed!);
    expect(calls, 2);
  });

  test('deleting and undoing are saved on the phone', () async {
    final c = await _seeded(store: SharedPrefsMoneyStore());
    final removed = await c.removeExpense(c.expenses[1].id);

    final afterDelete = MoneyController(store: SharedPrefsMoneyStore());
    await afterDelete.load();
    expect(afterDelete.expenses.length, 2);

    await c.restoreExpense(removed!);

    final afterUndo = MoneyController(store: SharedPrefsMoneyStore());
    await afterUndo.load();
    expect(afterUndo.expenses.length, 3);
    expect(
      afterUndo.expenses.map((e) => e.category).toList(),
      [
        ExpenseCategory.food,
        ExpenseCategory.transport,
        ExpenseCategory.rent,
      ],
    );
  });
}