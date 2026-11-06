import 'package:flutter/foundation.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/money/domain/budget_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/money/domain/score_calculator.dart';

/// An expense that was just deleted, plus where it sat in the list, so
/// Undo can put it back exactly where it was.
class RemovedExpense {
  const RemovedExpense({required this.expense, required this.index});

  final Expense expense;
  final int index;
}

/// Holds the user's budget and expenses and tells the screens when
/// something changes. If a [MoneyStore] is given, changes are saved.
class MoneyController extends ChangeNotifier {
  MoneyController({int budgetCents = 0, MoneyStore? store})
      : _budgetCents = budgetCents,
        _store = store;

  final MoneyStore? _store;
  final List<Expense> _expenses = [];
  int _budgetCents;
  int _idCounter = 0;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  int get budgetCents => _budgetCents;

  /// Totals for the current month.
  BudgetSummary get summary => BudgetCalculator.summarise(
    expenses: _expenses,
    budgetCents: _budgetCents,
    month: DateTime.now(),
  );

  /// Null until there is enough data (a budget, 3 expenses on 2+ days).
  int? get score => ScoreCalculator.calculate(
    summary: summary,
    expenses: _expenses,
    today: DateTime.now(),
  );

  /// Loads saved data (call once when the app starts).
  Future<void> load() async {
    final store = _store;
    if (store == null) return;

    final data = await store.load();
    _budgetCents = data.budgetCents;
    _expenses
      ..clear()
      ..addAll(data.expenses);
    notifyListeners();
  }

  Future<void> setBudgetCents(int cents) async {
    if (cents < 0) return;
    _budgetCents = cents;
    notifyListeners();
    await _persist();
  }

  Future<void> addExpense({
    required int amountCents,
    required ExpenseCategory category,
    DateTime? date,
    String note = '',
  }) async {
    if (amountCents <= 0) return;
    _expenses.add(Expense(
      // The counter keeps ids unique even when two expenses are added in
      // the same instant.
      id: '${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}',
      amountCents: amountCents,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
    ));
    notifyListeners();
    await _persist();
  }

  /// Deletes an expense. Returns what was removed (so the screen can offer
  /// Undo), or null if there was no expense with that id.
  Future<RemovedExpense?> removeExpense(String id) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index < 0) return null;
    final expense = _expenses.removeAt(index);
    notifyListeners();
    await _persist();
    return RemovedExpense(expense: expense, index: index);
  }

  /// Puts back an expense that was deleted (Undo). Does nothing if it is
  /// already in the list, so pressing Undo twice cannot duplicate it.
  Future<void> restoreExpense(RemovedExpense removed) async {
    if (_expenses.any((e) => e.id == removed.expense.id)) return;
    final at =
    removed.index > _expenses.length ? _expenses.length : removed.index;
    _expenses.insert(at, removed.expense);
    notifyListeners();
    await _persist();
  }

  /// Deletes the budget and every expense, and saves the empty state (so the
  /// home-screen widget is refreshed too).
  Future<void> clearAll() async {
    _budgetCents = 0;
    _expenses.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) return;
    try {
      await store.save(
        MoneyData(budgetCents: _budgetCents, expenses: List.of(_expenses)),
      );
    } catch (_) {
      debugPrint('Moreki: could not save money data');
    }
  }
}