import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/family_contribution/application/family_contribution_controller.dart';
import 'package:moreki/features/family_contribution/data/family_contribution_store.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';

class _MemoryStore implements FamilyContributionStore {
  FamilyContributionPlan stored = const FamilyContributionPlan();

  @override
  Future<FamilyContributionPlan> load() async => stored;

  @override
  Future<void> save(FamilyContributionPlan plan) async {
    stored = plan;
  }
}

void main() {
  test('starts with no plan', () {
    final c = FamilyContributionController();
    expect(c.hasPlan, isFalse);
    expect(c.result.safeCents, 0);
  });

  test('saving a plan works out the safe amount and tells listeners',
          () async {
        final c = FamilyContributionController();
        var notified = 0;
        c.addListener(() => notified++);

        final ok = await c.savePlan(
          takeHomeCents: 1000000,
          essentialsCents: 600000,
          savingsCents: 100000,
          requestedCents: 150000,
        );

        expect(ok, isTrue);
        expect(c.hasPlan, isTrue);
        expect(c.result.safeCents, 200000);
        expect(c.result.affordability, FamilyAffordability.comfortable);
        expect(notified, greaterThan(0));
      });

  test('rejects a plan with no pay or a negative amount', () async {
    final c = FamilyContributionController();
    expect(
      await c.savePlan(takeHomeCents: 0, essentialsCents: 100),
      isFalse,
    );
    expect(
      await c.savePlan(takeHomeCents: 1000, essentialsCents: -1),
      isFalse,
    );
    expect(
      await c.savePlan(
        takeHomeCents: 1000,
        essentialsCents: 100,
        savingsCents: -1,
      ),
      isFalse,
    );
    expect(
      await c.savePlan(
        takeHomeCents: 1000,
        essentialsCents: 100,
        requestedCents: -1,
      ),
      isFalse,
    );
    expect(c.hasPlan, isFalse);
  });

  test('savings and the request are optional', () async {
    final c = FamilyContributionController();
    expect(
      await c.savePlan(takeHomeCents: 800000, essentialsCents: 500000),
      isTrue,
    );
    expect(c.plan.savingsCents, 0);
    expect(c.plan.requestedCents, 0);
    expect(c.result.affordability, FamilyAffordability.none);
  });

  test('everything is saved and loads back in a new controller', () async {
    final store = _MemoryStore();
    final first = FamilyContributionController(store: store);
    await first.savePlan(
      takeHomeCents: 900000,
      essentialsCents: 500000,
      savingsCents: 50000,
      requestedCents: 120000,
    );

    final second = FamilyContributionController(store: store);
    await second.load();

    expect(second.plan.takeHomeCents, 900000);
    expect(second.plan.essentialsCents, 500000);
    expect(second.plan.savingsCents, 50000);
    expect(second.plan.requestedCents, 120000);
    expect(second.hasPlan, isTrue);
  });
}