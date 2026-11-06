import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/crisis/domain/crisis.dart';

void main() {
  group('CrisisCalculator', () {
    test('an empty plan has no data and no percent', () {
      final s = CrisisCalculator.summarise(const CrisisPlan());
      expect(s.essentialsCents, 0);
      expect(s.leftCents, 0);
      expect(s.hasData, isFalse);
      expect(s.essentialsPercent, isNull);
      expect(s.isShort, isFalse);
    });

    test('adds up all five essentials', () {
      final s = CrisisCalculator.summarise(
        const CrisisPlan(
          rentCents: 500000,
          foodCents: 200000,
          transportCents: 100000,
          debtCents: 150000,
          otherCents: 50000,
        ),
      );
      expect(s.essentialsCents, 1000000);
    });

    test('shows what is left when income covers essentials', () {
      final s = CrisisCalculator.summarise(
        const CrisisPlan(incomeCents: 1500000, rentCents: 1000000),
      );
      expect(s.leftCents, 500000);
      expect(s.isShort, isFalse);
      expect(s.essentialsPercent, 67);
    });

    test('shows a shortfall when essentials are more than income', () {
      final s = CrisisCalculator.summarise(
        const CrisisPlan(incomeCents: 800000, rentCents: 1000000),
      );
      expect(s.leftCents, -200000);
      expect(s.isShort, isTrue);
      expect(s.essentialsPercent, 125);
    });

    test('essentials with no income is short and has no percent', () {
      final s = CrisisCalculator.summarise(
        const CrisisPlan(foodCents: 100000),
      );
      expect(s.isShort, isTrue);
      expect(s.hasData, isTrue);
      expect(s.essentialsPercent, isNull);
    });
  });

  group('CrisisPlan json', () {
    test('survives a round trip', () {
      const plan = CrisisPlan(
        incomeCents: 1,
        rentCents: 2,
        foodCents: 3,
        transportCents: 4,
        debtCents: 5,
        otherCents: 6,
      );
      final back = CrisisPlan.fromJson(plan.toJson());
      expect(back.toJson(), plan.toJson());
    });

    test('rejects a negative amount', () {
      final json = const CrisisPlan().toJson()..['rentCents'] = -1;
      expect(() => CrisisPlan.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('rejects a missing field', () {
      final json = const CrisisPlan().toJson()..remove('debtCents');
      expect(() => CrisisPlan.fromJson(json), throwsA(anything));
    });
  });
}
