import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/emergency_fund/domain/emergency_fund.dart';

void main() {
  final today = DateTime(2026, 10, 29);

  // R5 000 essentials, 3 month goal, R1 000 a month.
  const plan = EmergencyFundPlan(
    essentialsCents: 500000,
    targetMonths: 3,
    monthlyContributionCents: 100000,
  );

  test('one week of essentials is 7/30 of a month, rounded', () {
    expect(EmergencyFundCalculator.weekOfEssentialsCents(500000), 116667);
  });

  test('works out the goal, what is left and the percentage', () {
    final p = EmergencyFundCalculator.calculate(
      plan: plan,
      savedCents: 300000,
      today: today,
    );
    expect(p.targetCents, 1500000);
    expect(p.remainingCents, 1200000);
    expect(p.fraction, closeTo(0.2, 0.0001));
    expect(p.isComplete, isFalse);
  });

  test('estimates the months to the goal at the monthly saving', () {
    final p = EmergencyFundCalculator.calculate(
      plan: plan,
      savedCents: 300000,
      today: today,
    );
    expect(p.monthsToGoal, 12);
    expect(p.estimatedFinish?.year, 2027);
    expect(p.estimatedFinish?.month, 10);
  });

  test('rounds the months up, never down', () {
    final p = EmergencyFundCalculator.calculate(
      plan: plan,
      savedCents: 299999,
      today: today,
    );
    expect(p.remainingCents, 1200001);
    expect(p.monthsToGoal, 13);
  });

  test('no monthly saving means no estimate', () {
    final p = EmergencyFundCalculator.calculate(
      plan: plan.copyWith(monthlyContributionCents: 0),
      savedCents: 300000,
      today: today,
    );
    expect(p.monthsToGoal, isNull);
    expect(p.estimatedFinish, isNull);
  });

  test('reaching the goal completes it', () {
    final p = EmergencyFundCalculator.calculate(
      plan: plan,
      savedCents: 1500000,
      today: today,
    );
    expect(p.isComplete, isTrue);
    expect(p.remainingCents, 0);
    expect(p.fraction, 1.0);
    expect(p.monthsToGoal, 0);
    expect(p.estimatedFinish, isNull);
  });

  test('saving more than the goal never goes above 100 percent', () {
    final p = EmergencyFundCalculator.calculate(
      plan: plan,
      savedCents: 2000000,
      today: today,
    );
    expect(p.fraction, 1.0);
    expect(p.remainingCents, 0);
  });

  test('with no essentials set there is no goal and no milestones', () {
    final p = EmergencyFundCalculator.calculate(
      plan: const EmergencyFundPlan(),
      savedCents: 5000,
      today: today,
    );
    expect(p.targetCents, 0);
    expect(p.fraction, 0.0);
    expect(p.isComplete, isFalse);
    expect(p.milestones, isEmpty);
    expect(p.monthsToGoal, isNull);
  });

  test('milestones stop at the chosen goal and show what is reached', () {
    final p = EmergencyFundCalculator.calculate(
      plan: plan,
      savedCents: 300000,
      today: today,
    );
    expect(p.milestones.map((m) => m.months), [0, 1, 3]);
    expect(p.milestones.map((m) => m.reached), [true, false, false]);

    final oneMonth = EmergencyFundCalculator.calculate(
      plan: plan.copyWith(targetMonths: 1),
      savedCents: 0,
      today: today,
    );
    expect(oneMonth.milestones.map((m) => m.months), [0, 1]);
  });

  test('a negative essentials amount is treated as zero', () {
    final p = EmergencyFundCalculator.calculate(
      plan: const EmergencyFundPlan(essentialsCents: -100),
      savedCents: 0,
      today: today,
    );
    expect(p.targetCents, 0);
  });
}