import 'package:moreki/features/money/domain/expense.dart';

/// Spend for one calendar day.
class DailySpend {
  const DailySpend({required this.day, required this.spentCents});

  /// Midnight at the start of the day (time of day is dropped).
  final DateTime day;
  final int spentCents;
}

class DailySpendCalculator {
  const DailySpendCalculator._();

  /// Totals real expenses per calendar day for the [days] days ending on
  /// [today] (inclusive), oldest first. Days with no expenses get 0.
  /// Money stays in whole cents.
  static List<DailySpend> lastDays({
    required List<Expense> expenses,
    required DateTime today,
    int days = 7,
  }) {
    final end = DateTime(today.year, today.month, today.day);
    final result = <DailySpend>[];

    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(end.year, end.month, end.day - i);
      var total = 0;
      for (final e in expenses) {
        if (e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day) {
          total += e.amountCents;
        }
      }
      result.add(DailySpend(day: day, spentCents: total));
    }
    return result;
  }
}
