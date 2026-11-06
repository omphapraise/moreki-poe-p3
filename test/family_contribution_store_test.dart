import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/family_contribution/data/family_contribution_store.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'moreki_family_contribution_v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsFamilyContributionStore', () {
    test('loads an empty plan when nothing has been saved', () async {
      SharedPreferences.setMockInitialValues({});

      final plan = await SharedPrefsFamilyContributionStore().load();

      expect(plan.takeHomeCents, 0);
      expect(plan.essentialsCents, 0);
      expect(plan.savingsCents, 0);
      expect(plan.requestedCents, 0);
    });

    test('saves and loads every number', () async {
      SharedPreferences.setMockInitialValues({});

      await SharedPrefsFamilyContributionStore().save(
        const FamilyContributionPlan(
          takeHomeCents: 1000050,
          essentialsCents: 600000,
          savingsCents: 100000,
          requestedCents: 150025,
        ),
      );

      // A brand new store object proves the data really came from storage.
      final loaded = await SharedPrefsFamilyContributionStore().load();

      expect(loaded.takeHomeCents, 1000050);
      expect(loaded.essentialsCents, 600000);
      expect(loaded.savingsCents, 100000);
      expect(loaded.requestedCents, 150025);
    });

    test('saving again replaces what was saved before', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPrefsFamilyContributionStore();

      await store.save(
        const FamilyContributionPlan(takeHomeCents: 500000),
      );
      await store.save(
        const FamilyContributionPlan(takeHomeCents: 700000),
      );

      expect((await store.load()).takeHomeCents, 700000);
    });

    test('loads an empty plan instead of crashing when data is damaged',
            () async {
          SharedPreferences.setMockInitialValues({_key: 'this is not json {'});

          final plan = await SharedPrefsFamilyContributionStore().load();

          expect(plan.takeHomeCents, 0);
        });

    test('loads an empty plan when saved JSON is missing fields', () async {
      SharedPreferences.setMockInitialValues({_key: '{}'});

      final plan = await SharedPrefsFamilyContributionStore().load();

      expect(plan.takeHomeCents, 0);
    });

    test('loads an empty plan when a saved amount is negative', () async {
      SharedPreferences.setMockInitialValues({
        _key: jsonEncode({
          'takeHomeCents': 500000,
          'essentialsCents': -1,
          'savingsCents': 0,
          'requestedCents': 0,
        }),
      });

      final plan = await SharedPrefsFamilyContributionStore().load();

      expect(plan.takeHomeCents, 0);
      expect(plan.essentialsCents, 0);
    });
  });
}