import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/domain/budget_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/money/domain/score_calculator.dart';

Expense _expense(int cents, DateTime date) => Expense(
  id: '${date.microsecondsSinceEpoch}-$cents',
  amountCents: cents,
  category: ExpenseCategory.food,
  date: date,
);

/// [count] expenses on days 1..count of November 2026 adding up to [total].
List<Expense> _spread(int total, int count) {
  final each = total ~/ count;
  return List.generate(
    count,
        (i) => _expense(
      i == count - 1 ? total - each * (count - 1) : each,
      DateTime(2026, 11, i + 1),
    ),
  );
}

int? _score(List<Expense> expenses, int budget, DateTime today) {
  final summary = BudgetCalculator.summarise(
    expenses: expenses,
    budgetCents: budget,
    month: today,
  );
  return ScoreCalculator.calculate(
    summary: summary,
    expenses: expenses,
    today: today,
  );
}

void main() {
  // 15 November 2026: exactly half of a 30-day month has passed.
  final midMonth = DateTime(2026, 11, 15);

  group('ScoreCalculator is locked until there is enough data', () {
    test('no budget', () {
      expect(_score(_spread(50000, 7), 0, midMonth), isNull);
    });

    test('fewer than 3 expenses', () {
      expect(_score(_spread(10000, 2), 100000, midMonth), isNull);
    });

    test('3 expenses but all on one day', () {
      final same = [
        _expense(1000, DateTime(2026, 11, 3)),
        _expense(1000, DateTime(2026, 11, 3)),
        _expense(1000, DateTime(2026, 11, 3)),
      ];
      expect(_score(same, 100000, midMonth), isNull);
    });
  });

  group('ScoreCalculator scores pace and tracking', () {
    test('on pace and tracked daily = 100', () {
      expect(_score(_spread(50000, 7), 100000, midMonth), 100);
    });

    test('1.5x the pace halves the pace points', () {
      // pace 40 + tracking 20
      expect(_score(_spread(75000, 7), 100000, midMonth), 60);
    });

    test('2x the pace gives 0 pace points', () {
      // pace 0 + tracking 20
      expect(_score(_spread(100000, 7), 100000, midMonth), 20);
    });

    test('few tracked days lowers the tracking points', () {
      // pace 80 + tracking 20 * 3/7 = 88.57 -> 89
      expect(_score(_spread(10000, 3), 100000, midMonth), 89);
    });

    test('over budget is capped at 40', () {
      final endOfMonth = DateTime(2026, 11, 30);
      expect(_score(_spread(150000, 7), 100000, endOfMonth), 40);
    });

    test('a single small expense can no longer give 100', () {
      expect(_score(_spread(5000, 1), 100000, midMonth), isNull);
    });
  });
}