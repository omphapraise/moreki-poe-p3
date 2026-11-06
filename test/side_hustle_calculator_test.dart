import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/side_hustle/domain/side_hustle.dart';

HustleEntry _e(
  String id,
  HustleEntryType type,
  int cents,
  DateTime date,
) =>
    HustleEntry(id: id, type: type, amountCents: cents, date: date);

void main() {
  group('SideHustleCalculator', () {
    test('an empty list gives zeros and no percent', () {
      final s = SideHustleCalculator.summarise(const []);
      expect(s.incomeCents, 0);
      expect(s.costCents, 0);
      expect(s.keepCents, 0);
      expect(s.entryCount, 0);
      expect(s.keepPercent, isNull);
      expect(s.isLoss, isFalse);
    });

    test('keeps income minus costs, exactly, in cents', () {
      final s = SideHustleCalculator.summarise([
        _e('a', HustleEntryType.income, 50000, DateTime(2026, 11, 1)),
        _e('b', HustleEntryType.income, 25050, DateTime(2026, 11, 2)),
        _e('c', HustleEntryType.cost, 12000, DateTime(2026, 11, 3)),
      ]);
      expect(s.incomeCents, 75050);
      expect(s.costCents, 12000);
      expect(s.keepCents, 63050);
      expect(s.entryCount, 3);
      expect(s.keepPercent, 84);
    });

    test('rounds the keep percent to the nearest whole percent', () {
      final third = SideHustleCalculator.summarise([
        _e('a', HustleEntryType.income, 30000, DateTime(2026, 11, 1)),
        _e('b', HustleEntryType.cost, 20000, DateTime(2026, 11, 1)),
      ]);
      expect(third.keepPercent, 33);

      final twoThirds = SideHustleCalculator.summarise([
        _e('a', HustleEntryType.income, 30000, DateTime(2026, 11, 1)),
        _e('b', HustleEntryType.cost, 10000, DateTime(2026, 11, 1)),
      ]);
      expect(twoThirds.keepPercent, 67);
    });

    test('a loss is negative and flagged', () {
      final s = SideHustleCalculator.summarise([
        _e('a', HustleEntryType.income, 10000, DateTime(2026, 11, 1)),
        _e('b', HustleEntryType.cost, 15000, DateTime(2026, 11, 1)),
      ]);
      expect(s.keepCents, -5000);
      expect(s.isLoss, isTrue);
      expect(s.keepPercent, -50);
    });

    test('costs with no income give a loss and no percent', () {
      final s = SideHustleCalculator.summarise([
        _e('a', HustleEntryType.cost, 5000, DateTime(2026, 11, 1)),
      ]);
      expect(s.keepCents, -5000);
      expect(s.keepPercent, isNull);
    });

    test('can count one calendar month only', () {
      final entries = [
        _e('a', HustleEntryType.income, 100000, DateTime(2026, 10, 30)),
        _e('b', HustleEntryType.income, 20000, DateTime(2026, 11, 2)),
        _e('c', HustleEntryType.cost, 5000, DateTime(2026, 11, 20)),
        _e('d', HustleEntryType.income, 99900, DateTime(2025, 11, 5)),
      ];
      final s = SideHustleCalculator.summarise(
        entries,
        month: DateTime(2026, 11, 15),
      );
      expect(s.incomeCents, 20000);
      expect(s.costCents, 5000);
      expect(s.keepCents, 15000);
      expect(s.entryCount, 2);
      expect(s.keepPercent, 75);
    });
  });

  group('HustleEntry JSON', () {
    test('survives a round trip', () {
      final original = HustleEntry(
        id: 'x',
        type: HustleEntryType.cost,
        amountCents: 4550,
        date: DateTime(2026, 11, 4, 9, 30),
        note: 'bread flour',
      );
      final copy = HustleEntry.fromJson(original.toJson());
      expect(copy.id, 'x');
      expect(copy.type, HustleEntryType.cost);
      expect(copy.amountCents, 4550);
      expect(copy.date, DateTime(2026, 11, 4, 9, 30));
      expect(copy.note, 'bread flour');
    });

    test('a missing note becomes empty text', () {
      final e = HustleEntry.fromJson({
        'id': 'x',
        'type': 'income',
        'amountCents': 100,
        'date': DateTime(2026, 11, 4).toIso8601String(),
      });
      expect(e.note, '');
    });

    test('rejects an unknown type', () {
      expect(
        () => HustleEntry.fromJson({
          'id': 'x',
          'type': 'gift',
          'amountCents': 100,
          'date': DateTime(2026, 11, 4).toIso8601String(),
        }),
        throwsA(anything),
      );
    });

    test('rejects an amount of zero or less', () {
      expect(
        () => HustleEntry.fromJson({
          'id': 'x',
          'type': 'income',
          'amountCents': 0,
          'date': DateTime(2026, 11, 4).toIso8601String(),
        }),
        throwsA(anything),
      );
    });
  });
}
