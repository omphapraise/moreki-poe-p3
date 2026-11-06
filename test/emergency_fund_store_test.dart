import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/emergency_fund/data/emergency_fund_store.dart';
import 'package:moreki/features/emergency_fund/domain/emergency_fund.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'moreki_emergency_fund_v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsEmergencyFundStore', () {
    test('loads empty data when nothing has been saved', () async {
      SharedPreferences.setMockInitialValues({});

      final data = await SharedPrefsEmergencyFundStore().load();

      expect(data.plan.essentialsCents, 0);
      expect(data.plan.targetMonths, 3);
      expect(data.plan.monthlyContributionCents, 0);
      expect(data.deposits, isEmpty);
      expect(data.savedCents, 0);
    });

    test('saves and loads the plan and deposits', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPrefsEmergencyFundStore();

      await store.save(
        EmergencyFundData(
          plan: const EmergencyFundPlan(
            essentialsCents: 500000,
            targetMonths: 6,
            monthlyContributionCents: 50000,
          ),
          deposits: [
            FundDeposit(
              id: 'a',
              amountCents: 100000,
              date: DateTime(2026, 10, 1, 9, 30),
            ),
            FundDeposit(
              id: 'b',
              amountCents: 25050,
              date: DateTime(2026, 10, 15, 18, 5),
            ),
          ],
        ),
      );

      // A brand new store object proves the data really came from storage.
      final loaded = await SharedPrefsEmergencyFundStore().load();

      expect(loaded.plan.essentialsCents, 500000);
      expect(loaded.plan.targetMonths, 6);
      expect(loaded.plan.monthlyContributionCents, 50000);
      expect(loaded.deposits.length, 2);
      expect(loaded.deposits[0].id, 'a');
      expect(loaded.deposits[0].amountCents, 100000);
      expect(loaded.deposits[0].date, DateTime(2026, 10, 1, 9, 30));
      expect(loaded.deposits[1].id, 'b');
      expect(loaded.deposits[1].amountCents, 25050);
      expect(loaded.savedCents, 125050);
    });

    test('saving again replaces what was saved before', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPrefsEmergencyFundStore();

      await store.save(
        EmergencyFundData(
          plan: const EmergencyFundPlan(essentialsCents: 100000),
          deposits: [
            FundDeposit(id: 'old', amountCents: 5000, date: DateTime(2026, 1, 1)),
          ],
        ),
      );
      await store.save(
        const EmergencyFundData(
          plan: EmergencyFundPlan(essentialsCents: 200000),
        ),
      );

      final loaded = await store.load();

      expect(loaded.plan.essentialsCents, 200000);
      expect(loaded.deposits, isEmpty);
    });

    test('loads empty data instead of crashing when saved data is damaged',
            () async {
          SharedPreferences.setMockInitialValues({_key: 'this is not json {'});

          final data = await SharedPrefsEmergencyFundStore().load();

          expect(data.plan.essentialsCents, 0);
          expect(data.plan.targetMonths, 3);
          expect(data.deposits, isEmpty);
        });

    test('loads empty data when saved JSON is missing fields', () async {
      SharedPreferences.setMockInitialValues({_key: '{}'});

      final data = await SharedPrefsEmergencyFundStore().load();

      expect(data.plan.essentialsCents, 0);
      expect(data.deposits, isEmpty);
    });

    test('an unknown goal length falls back to 3 months', () async {
      SharedPreferences.setMockInitialValues({
        _key: jsonEncode({
          'essentialsCents': 400000,
          'targetMonths': 4,
          'monthlyContributionCents': 30000,
          'deposits': <dynamic>[],
        }),
      });

      final data = await SharedPrefsEmergencyFundStore().load();

      expect(data.plan.targetMonths, 3);
      expect(data.plan.essentialsCents, 400000);
      expect(data.plan.monthlyContributionCents, 30000);
    });
  });
}