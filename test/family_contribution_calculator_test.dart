import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';

// R10 000 take-home, R6 000 essentials, R1 000 savings by default.
FamilyContributionPlan _plan({
  int takeHome = 1000000,
  int essentials = 600000,
  int savings = 100000,
  int requested = 0,
}) =>
    FamilyContributionPlan(
      takeHomeCents: takeHome,
      essentialsCents: essentials,
      savingsCents: savings,
      requestedCents: requested,
    );

void main() {
  group('FamilyContributionCalculator', () {
    test('works out the buffer, room and safe amount', () {
      final r = FamilyContributionCalculator.calculate(_plan());
      expect(r.bufferCents, 100000);
      expect(r.roomCents, 300000);
      expect(r.safeCents, 200000);
      expect(r.safePercent, 20);
      expect(r.affordability, FamilyAffordability.none);
      expect(r.shortfallCents, 0);
    });

    test('a request within the safe amount is comfortable', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(requested: 150000),
      );
      expect(r.affordability, FamilyAffordability.comfortable);
      expect(r.shortfallCents, 0);
      expect(r.leftAfterRequestCents, 150000);
    });

    test('exactly the safe amount is still comfortable', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(requested: 200000),
      );
      expect(r.affordability, FamilyAffordability.comfortable);
    });

    test('a request that uses the buffer is tight', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(requested: 250000),
      );
      expect(r.affordability, FamilyAffordability.tight);
      expect(r.shortfallCents, 50000);
      expect(r.leftAfterRequestCents, 50000);
    });

    test('using all the room is still tight, with nothing left over', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(requested: 300000),
      );
      expect(r.affordability, FamilyAffordability.tight);
      expect(r.leftAfterRequestCents, 0);
    });

    test('one cent above the room is too much', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(requested: 300001),
      );
      expect(r.affordability, FamilyAffordability.tooMuch);
      expect(r.shortfallCents, 100001);
      expect(r.leftAfterRequestCents, -1);
    });

    test('when essentials eat the pay, nothing is safe to send', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(takeHome: 500000, essentials: 480000, savings: 0),
      );
      expect(r.bufferCents, 50000);
      expect(r.roomCents, 20000);
      expect(r.safeCents, 0);
      expect(r.safePercent, 0);

      final small = FamilyContributionCalculator.calculate(
        _plan(
          takeHome: 500000,
          essentials: 480000,
          savings: 0,
          requested: 10000,
        ),
      );
      expect(small.affordability, FamilyAffordability.tight);

      final big = FamilyContributionCalculator.calculate(
        _plan(
          takeHome: 500000,
          essentials: 480000,
          savings: 0,
          requested: 30000,
        ),
      );
      expect(big.affordability, FamilyAffordability.tooMuch);
    });

    test('costs above the pay never give a negative safe amount', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(takeHome: 300000, essentials: 400000, savings: 50000),
      );
      expect(r.roomCents, 0);
      expect(r.safeCents, 0);
    });

    test('the buffer is rounded to the cent', () {
      expect(FamilyContributionCalculator.bufferCents(1005), 101);
      expect(FamilyContributionCalculator.bufferCents(1004), 100);
      expect(FamilyContributionCalculator.bufferCents(0), 0);
    });

    test('negative inputs are treated as zero', () {
      final r = FamilyContributionCalculator.calculate(
        _plan(takeHome: 100000, essentials: -500, savings: -1),
      );
      expect(r.essentialsCents, 0);
      expect(r.savingsCents, 0);
      expect(r.roomCents, 100000);
      expect(r.safeCents, 90000);
    });

    test('no take-home gives all zeros without crashing', () {
      final r = FamilyContributionCalculator.calculate(
        const FamilyContributionPlan(),
      );
      expect(r.safeCents, 0);
      expect(r.safePercent, 0);
      expect(r.affordability, FamilyAffordability.none);
    });
  });
}