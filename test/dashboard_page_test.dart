import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/format/money_parts.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/dashboard/dashboard_page.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/profile/application/profile_controller.dart';

const _anyCategory = ExpenseCategory.transport;

// 29 Oct 2026, 09:00 (a Thursday morning).
DateTime _morning() => DateTime(2026, 10, 29, 9);

Future<MoneyController> _pump(
    WidgetTester tester, {
      ProfileController? profile,
      DateTime Function()? clock,
    }) async {
  tester.view.physicalSize = const Size(900, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final money = MoneyController();
  addTearDown(money.dispose);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: DashboardPage(
        controller: money,
        profile: profile,
        clock: clock ?? _morning,
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return money;
}

ProfileController _profile() {
  final p = ProfileController(clock: _morning);
  addTearDown(p.dispose);
  return p;
}

final _paydayWords = RegExp('payday', caseSensitive: false);

void main() {
  testWidgets('the hero shows the cents small, as their own text',
          (tester) async {
        final money = await _pump(tester);
        await money.setBudgetCents(8000000);
        await money.addExpense(amountCents: 2200000, category: _anyCategory);
        await tester.pumpAndSettle();

        final parts = splitRandForDisplay(formatRand(money.summary.remainingCents));
        expect(parts.cents, isNotNull);
        expect(find.text(parts.whole), findsOneWidget);
        expect(find.text(parts.cents!), findsOneWidget);
      });

  testWidgets('with no budget the hero shows zero with small cents',
          (tester) async {
        await _pump(tester);
        final parts = splitRandForDisplay(formatRand(0));
        expect(find.text(parts.whole), findsOneWidget);
        expect(find.text(parts.cents!), findsOneWidget);
      });

  testWidgets('greets by time of day when no profile is given',
          (tester) async {
        await _pump(tester);
        expect(find.text('Good morning'), findsOneWidget);
      });

  testWidgets('greets by time of day: afternoon and evening',
          (tester) async {
        await _pump(tester, clock: () => DateTime(2026, 10, 29, 14));
        expect(find.text('Good afternoon'), findsOneWidget);
        await _pump(tester, clock: () => DateTime(2026, 10, 29, 20));
        expect(find.text('Good evening'), findsOneWidget);
      });

  testWidgets('greets by name when the profile has one', (tester) async {
    final profile = _profile();
    await profile.saveDetails(displayName: 'Thandi');
    await _pump(tester, profile: profile);
    expect(find.text('Good morning, Thandi'), findsOneWidget);
  });

  testWidgets('a profile with no name gets the plain greeting',
          (tester) async {
        await _pump(tester, profile: _profile());
        expect(find.text('Good morning'), findsOneWidget);
      });

  testWidgets('there is no payday line when no payday is set',
          (tester) async {
        await _pump(tester, profile: _profile());
        expect(find.textContaining(_paydayWords), findsNothing);
      });

  testWidgets('shows how many days to payday', (tester) async {
    final profile = _profile();
    await profile.saveDetails(displayName: '', paydayDay: 31);
    await _pump(tester, profile: profile);
    // 29 Oct to 31 Oct.
    expect(find.text('2 days to payday'), findsOneWidget);
  });

  testWidgets('words payday tomorrow and payday today properly',
          (tester) async {
        final tomorrow = _profile();
        await tomorrow.saveDetails(displayName: '', paydayDay: 30);
        await _pump(tester, profile: tomorrow);
        expect(find.text('Payday is tomorrow'), findsOneWidget);

        final today = _profile();
        await today.saveDetails(displayName: '', paydayDay: 29);
        await _pump(tester, profile: today);
        expect(find.text('Payday is today'), findsOneWidget);
      });

  testWidgets('Home updates when the profile changes', (tester) async {
    final profile = _profile();
    await _pump(tester, profile: profile);
    expect(find.text('Good morning'), findsOneWidget);

    await profile.saveDetails(displayName: 'Sipho', paydayDay: 31);
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Sipho'), findsOneWidget);
    expect(find.text('2 days to payday'), findsOneWidget);
  });
}