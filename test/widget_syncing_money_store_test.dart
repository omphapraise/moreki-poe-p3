import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/widget/data/widget_syncing_money_store.dart';
import 'package:moreki/features/widget/data/widget_updater.dart';
import 'package:moreki/features/widget/domain/widget_snapshot.dart';

class _MemoryStore implements MoneyStore {
  MoneyData stored = const MoneyData();

  @override
  Future<MoneyData> load() async => stored;

  @override
  Future<void> save(MoneyData data) async {
    stored = data;
  }
}

class _RecordingUpdater implements WidgetUpdater {
  final List<WidgetSnapshot> snapshots = [];

  @override
  Future<void> update(WidgetSnapshot snapshot) async {
    snapshots.add(snapshot);
  }
}

class _BrokenUpdater implements WidgetUpdater {
  @override
  Future<void> update(WidgetSnapshot snapshot) async {
    throw Exception('no widget here');
  }
}

MoneyData _data() => MoneyData(
  budgetCents: 100000,
  expenses: [
    Expense(
      id: 'a',
      amountCents: 25000,
      category: ExpenseCategory.food,
      date: DateTime(2026, 10, 28),
    ),
  ],
);

void main() {
  DateTime clock() => DateTime(2026, 10, 28, 9, 5);

  test('saving stores the data and refreshes the widget', () async {
    final inner = _MemoryStore();
    final updater = _RecordingUpdater();
    final store = WidgetSyncingMoneyStore(
      inner: inner,
      updater: updater,
      clock: clock,
    );

    await store.save(_data());

    expect(inner.stored.budgetCents, 100000);
    expect(inner.stored.expenses.length, 1);
    expect(updater.snapshots.length, 1);
    expect(updater.snapshots.single.leftValue, 'R 750.00');
  });

  test('loading returns the saved data and refreshes the widget', () async {
    final inner = _MemoryStore()..stored = _data();
    final updater = _RecordingUpdater();
    final store = WidgetSyncingMoneyStore(
      inner: inner,
      updater: updater,
      clock: clock,
    );

    final loaded = await store.load();

    expect(loaded.budgetCents, 100000);
    expect(updater.snapshots.length, 1);
    expect(updater.snapshots.single.asOf, 'As of 28 Oct, 09:05');
  });

  test('a broken widget never stops the data being saved or loaded', () async {
    final inner = _MemoryStore();
    final store = WidgetSyncingMoneyStore(
      inner: inner,
      updater: _BrokenUpdater(),
      clock: clock,
    );

    await store.save(_data());
    expect(inner.stored.budgetCents, 100000);

    final loaded = await store.load();
    expect(loaded.budgetCents, 100000);
  });
}