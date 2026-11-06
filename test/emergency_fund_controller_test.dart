import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/emergency_fund/application/emergency_fund_controller.dart';
import 'package:moreki/features/emergency_fund/data/emergency_fund_store.dart';

class _MemoryStore implements EmergencyFundStore {
  EmergencyFundData stored = const EmergencyFundData();

  @override
  Future<EmergencyFundData> load() async => stored;

  @override
  Future<void> save(EmergencyFundData data) async {
    stored = data;
  }
}

void main() {
  DateTime clock() => DateTime(2026, 10, 29, 10);

  test('starts empty', () {
    final c = EmergencyFundController(clock: clock);
    expect(c.savedCents, 0);
    expect(c.deposits, isEmpty);
    expect(c.progress.targetCents, 0);
  });

  test('saving a plan sets the goal and tells listeners', () async {
    final c = EmergencyFundController(clock: clock);
    var notified = 0;
    c.addListener(() => notified++);

    final ok = await c.savePlan(
      essentialsCents: 500000,
      monthlyContributionCents: 50000,
    );

    expect(ok, isTrue);
    expect(c.progress.targetCents, 1500000);
    expect(notified, greaterThan(0));
  });

  test('rejects a plan with no essentials or a negative saving', () async {
    final c = EmergencyFundController(clock: clock);
    expect(
      await c.savePlan(essentialsCents: 0, monthlyContributionCents: 0),
      isFalse,
    );
    expect(
      await c.savePlan(essentialsCents: 100, monthlyContributionCents: -1),
      isFalse,
    );
    expect(c.plan.essentialsCents, 0);
  });

  test('adding savings adds up and rejects zero or negative', () async {
    final c = EmergencyFundController(clock: clock);
    expect(await c.addDeposit(amountCents: 25000), isTrue);
    expect(await c.addDeposit(amountCents: 10000), isTrue);
    expect(await c.addDeposit(amountCents: 0), isFalse);
    expect(await c.addDeposit(amountCents: -5), isFalse);
    expect(c.savedCents, 35000);
    expect(c.deposits.length, 2);
  });

  test('only 1, 3 or 6 month goals are accepted', () async {
    final c = EmergencyFundController(clock: clock);
    expect(await c.setTargetMonths(2), isFalse);
    expect(c.plan.targetMonths, 3);
    expect(await c.setTargetMonths(6), isTrue);
    expect(c.plan.targetMonths, 6);
  });

  test('everything is saved and loads back in a new controller', () async {
    final store = _MemoryStore();
    final first = EmergencyFundController(store: store, clock: clock);
    await first.savePlan(
      essentialsCents: 400000,
      monthlyContributionCents: 20000,
    );
    await first.setTargetMonths(6);
    await first.addDeposit(amountCents: 15000);

    final second = EmergencyFundController(store: store, clock: clock);
    await second.load();

    expect(second.plan.essentialsCents, 400000);
    expect(second.plan.targetMonths, 6);
    expect(second.plan.monthlyContributionCents, 20000);
    expect(second.savedCents, 15000);
    expect(second.deposits.length, 1);
  });
}