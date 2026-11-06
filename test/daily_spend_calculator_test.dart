import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/money/domain/daily_spend_calculator.dart';
import 'package:moreki/features/money/domain/expense.dart';

Expense _e(String id, int cents, DateTime date) => Expense(
      id: id,
      amountCents: cents,
      category: ExpenseCategory.food,
      date: date,
    );

void main() {
  final today = DateTime(2026, 11, 1, 14, 30);

  test('returns 7 days, oldest first, ending today', () {
    final r = DailySpendCalculator.lastDays(expenses: [], today: today);
    expect(r.length, 7);
    expect(r.first.day, DateTime(2026, 10, 26));
    expect(r.last.day, DateTime(2026, 11, 1));
  });

  test('no expenses gives zero on every day', () {
    final r = DailySpendCalculator.lastDays(expenses: [], today: today);
    expect(r.every((d) => d.spentCents == 0), isTrue);
  });

  test('adds several expenses on the same day, ignoring time of day', () {
    final r = DailySpendCalculator.lastDays(
      expenses: [
        _e('a', 1200000, DateTime(2026, 11, 1, 0, 5)),
        _e('b', 450000, DateTime(2026, 11, 1, 23, 59)),
      ],
      today: today,
    );
    expect(r.last.spentCents, 1650000);
  });

  test('crosses the month boundary (31 Oct is yesterday)', () {
    final r = DailySpendCalculator.lastDays(
      expenses: [_e('a', 1800000, DateTime(2026, 10, 31, 9))],
      today: today,
    );
    expect(r[5].day, DateTime(2026, 10, 31));
    expect(r[5].spentCents, 1800000);
    expect(r.last.spentCents, 0);
  });

  test('ignores expenses older than the window and in the future', () {
    final r = DailySpendCalculator.lastDays(
      expenses: [
        _e('old', 99900, DateTime(2026, 10, 20)),
        _e('future', 88800, DateTime(2026, 11, 2)),
      ],
      today: today,
    );
    expect(r.fold<int>(0, (s, d) => s + d.spentCents), 0);
  });
}
