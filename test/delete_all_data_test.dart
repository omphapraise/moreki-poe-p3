import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/emergency_fund/application/emergency_fund_controller.dart';
import 'package:moreki/features/emergency_fund/data/emergency_fund_store.dart';
import 'package:moreki/features/family_contribution/application/family_contribution_controller.dart';
import 'package:moreki/features/family_contribution/data/family_contribution_store.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/profile/application/profile_controller.dart';
import 'package:moreki/features/profile/data/profile_store.dart';
import 'package:moreki/features/profile/domain/profile.dart';
import 'package:moreki/features/profile/presentation/profile_page.dart';

class _FakeMoneyStore implements MoneyStore {
  MoneyData? last;

  @override
  Future<MoneyData> load() async =>
      last ?? MoneyData(budgetCents: 0, expenses: const []);

  @override
  Future<void> save(MoneyData data) async => last = data;
}

class _FakeFundStore implements EmergencyFundStore {
  EmergencyFundData? last;

  @override
  Future<EmergencyFundData> load() async =>
      last ?? const EmergencyFundData();

  @override
  Future<void> save(EmergencyFundData data) async => last = data;
}

class _FakeFamilyStore implements FamilyContributionStore {
  FamilyContributionPlan? last;

  @override
  Future<FamilyContributionPlan> load() async =>
      last ?? const FamilyContributionPlan();

  @override
  Future<void> save(FamilyContributionPlan plan) async => last = plan;
}

class _FakeProfileStore implements ProfileStore {
  ProfileSettings? last;

  @override
  Future<ProfileSettings> load() async => last ?? const ProfileSettings();

  @override
  Future<void> save(ProfileSettings settings) async => last = settings;
}

void main() {
  group('clearAll', () {
    test('MoneyController resets, notifies once and saves empty', () async {
      final store = _FakeMoneyStore();
      final c = MoneyController(store: store);
      await c.setBudgetCents(500000);
      await c.addExpense(amountCents: 2500, category: ExpenseCategory.food);
      expect(c.expenses, hasLength(1));

      var notifications = 0;
      c.addListener(() => notifications++);
      await c.clearAll();

      expect(c.budgetCents, 0);
      expect(c.expenses, isEmpty);
      expect(notifications, 1);
      expect(store.last!.budgetCents, 0);
      expect(store.last!.expenses, isEmpty);
    });

    test('EmergencyFundController resets, notifies once and saves empty',
            () async {
          final store = _FakeFundStore();
          final c = EmergencyFundController(store: store);
          await c.savePlan(
            essentialsCents: 1000000,
            monthlyContributionCents: 100000,
          );
          await c.addDeposit(amountCents: 50000);
          expect(c.savedCents, 50000);

          var notifications = 0;
          c.addListener(() => notifications++);
          await c.clearAll();

          expect(c.savedCents, 0);
          expect(c.deposits, isEmpty);
          expect(c.plan.essentialsCents, 0);
          expect(c.plan.monthlyContributionCents, 0);
          expect(notifications, 1);
          expect(store.last!.deposits, isEmpty);
          expect(store.last!.plan.essentialsCents, 0);
        });

    test('FamilyContributionController resets, notifies once and saves empty',
            () async {
          final store = _FakeFamilyStore();
          final c = FamilyContributionController(store: store);
          await c.savePlan(takeHomeCents: 2000000, essentialsCents: 1000000);
          expect(c.hasPlan, isTrue);

          var notifications = 0;
          c.addListener(() => notifications++);
          await c.clearAll();

          expect(c.hasPlan, isFalse);
          expect(c.plan.takeHomeCents, 0);
          expect(notifications, 1);
          expect(store.last!.takeHomeCents, 0);
          expect(store.last!.essentialsCents, 0);
        });

    test('ProfileController resets, notifies once and saves defaults',
            () async {
          final store = _FakeProfileStore();
          final c = ProfileController(store: store);
          await c.load();
          await c.saveDetails(displayName: 'Thandi', paydayDay: 25);
          await c.setLanguage('fr');
          expect(c.settings.displayName, 'Thandi');

          var notifications = 0;
          c.addListener(() => notifications++);
          await c.clearAll();

          expect(c.settings.displayName, '');
          expect(c.settings.languageCode, 'en');
          expect(c.settings.paydayDay, isNull);
          expect(c.payday, isNull);
          expect(c.loaded, isTrue);
          expect(notifications, 1);
          expect(store.last!.displayName, '');
          expect(store.last!.paydayDay, isNull);
        });
  });

  group('Profile page: delete all my data', () {
    Future<ProfileController> loadedProfile() async {
      final store = _FakeProfileStore()
        ..last = const ProfileSettings(displayName: 'Thandi', paydayDay: 25);
      final c = ProfileController(store: store);
      await c.load();
      return c;
    }

    Future<void> pumpPage(
        WidgetTester tester,
        ProfileController controller, {
          Future<void> Function()? onDeleteAllData,
        }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ProfilePage(
              controller: controller,
              onDeleteAllData: onDeleteAllData,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> showDeleteButton(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.byKey(const Key('deleteAllDataButton')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('no delete button when no callback is given', (tester) async {
      final controller = await loadedProfile();
      await pumpPage(tester, controller);
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('deleteAllDataButton')), findsNothing);
    });

    testWidgets('cancel keeps the data', (tester) async {
      final controller = await loadedProfile();
      var called = false;
      await pumpPage(
        tester,
        controller,
        onDeleteAllData: () async {
          called = true;
        },
      );

      await showDeleteButton(tester);
      await tester.tap(find.byKey(const Key('deleteAllDataButton')));
      await tester.pumpAndSettle();
      expect(find.text('Delete all my data?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancelDeleteAllButton')));
      await tester.pumpAndSettle();

      expect(find.text('Delete all my data?'), findsNothing);
      expect(called, isFalse);
      expect(controller.settings.displayName, 'Thandi');
    });

    testWidgets('confirm clears the data, the fields and shows a message',
            (tester) async {
          final controller = await loadedProfile();
          var called = false;
          await pumpPage(
            tester,
            controller,
            onDeleteAllData: () async {
              called = true;
              await controller.clearAll();
            },
          );

          await showDeleteButton(tester);
          await tester.tap(find.byKey(const Key('deleteAllDataButton')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('confirmDeleteAllButton')));
          await tester.pumpAndSettle();

          expect(called, isTrue);
          expect(controller.settings.displayName, '');
          expect(controller.settings.paydayDay, isNull);
          expect(
            find.text('All your data was deleted from this phone'),
            findsOneWidget,
          );

          // Scroll back up and check the text boxes are empty.
          await tester.drag(find.byType(ListView), const Offset(0, 3000));
          await tester.pumpAndSettle();
          final nameField = tester.widget<TextField>(
            find.byKey(const Key('profileNameField')),
          );
          final paydayField = tester.widget<TextField>(
            find.byKey(const Key('profilePaydayField')),
          );
          expect(nameField.controller!.text, '');
          expect(paydayField.controller!.text, '');
        });
  });
}