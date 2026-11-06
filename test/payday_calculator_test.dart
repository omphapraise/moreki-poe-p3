import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/profile/domain/profile.dart';

void main() {
  group('PaydayCalculator', () {
    test('payday later this month', () {
      final p = PaydayCalculator.next(DateTime(2026, 10, 29), 31);
      expect(p.date, DateTime(2026, 10, 31));
      expect(p.daysAway, 2);
    });

    test('payday already passed rolls into next month', () {
      final p = PaydayCalculator.next(DateTime(2026, 10, 29), 25);
      expect(p.date, DateTime(2026, 11, 25));
      expect(p.daysAway, 27);
    });

    test('payday today is 0 days away', () {
      final p = PaydayCalculator.next(DateTime(2026, 10, 29), 29);
      expect(p.date, DateTime(2026, 10, 29));
      expect(p.daysAway, 0);
    });

    test('payday tomorrow is 1 day away', () {
      final p = PaydayCalculator.next(DateTime(2026, 10, 29), 30);
      expect(p.daysAway, 1);
    });

    test('the time of day does not change the answer', () {
      final p = PaydayCalculator.next(DateTime(2026, 10, 29, 23, 59), 30);
      expect(p.daysAway, 1);
    });

    test('rolls over the new year', () {
      final p = PaydayCalculator.next(DateTime(2026, 12, 29), 5);
      expect(p.date, DateTime(2027, 1, 5));
      expect(p.daysAway, 7);
    });

    test('payday 31 falls on the last day of a short month', () {
      final p = PaydayCalculator.next(DateTime(2027, 2, 10), 31);
      expect(p.date, DateTime(2027, 2, 28));
      expect(p.daysAway, 18);
    });

    test('payday 31 in a leap February is the 29th', () {
      final p = PaydayCalculator.next(DateTime(2028, 2, 15), 31);
      expect(p.date, DateTime(2028, 2, 29));
      expect(p.daysAway, 14);
    });

    test('payday 31 after a 30-day month ends rolls to the next 30th', () {
      final p = PaydayCalculator.next(DateTime(2026, 11, 1), 31);
      expect(p.date, DateTime(2026, 11, 30));
    });
  });
}