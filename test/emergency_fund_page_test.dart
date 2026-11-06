import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/emergency_fund/application/emergency_fund_controller.dart';
import 'package:moreki/features/emergency_fund/data/emergency_fund_store.dart';
import 'package:moreki/features/emergency_fund/presentation/emergency_fund_page.dart';

class _MemoryStore implements EmergencyFundStore {
  EmergencyFundData stored = const EmergencyFundData();

  @override
  Future<EmergencyFundData> load() async => stored;

  @override
  Future<void> save(EmergencyFundData data) async {
    stored = data;
  }
}

Future<void> _pumpPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final controller = EmergencyFundController(
    store: _MemoryStore(),
    clock: () => DateTime(2026, 10, 29),
  );
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: EmergencyFundPage(controller: controller),
    ),
  );
}

void main() {
  testWidgets('asks for monthly essentials when nothing is set', (tester) async {
    await _pumpPage(tester);
    expect(
      find.text('Set your monthly essentials to see your goal.'),
      findsOneWidget,
    );
  });

  testWidgets('saving a plan shows the goal and adding savings moves it',
          (tester) async {
        await _pumpPage(tester);

        await tester.enterText(find.byKey(const Key('fundEssentialsField')), '5000');
        await tester.enterText(find.byKey(const Key('fundMonthlyField')), '500');
        await tester.tap(find.byKey(const Key('savePlanButton')));
        await tester.pumpAndSettle();

        expect(
          find.text('of R 15 000.00 goal (3 months of essentials)'),
          findsOneWidget,
        );

        await tester.enterText(find.byKey(const Key('fundDepositField')), '1000');
        await tester.tap(find.byKey(const Key('addDepositButton')));
        await tester.pumpAndSettle();

        expect(find.text('R 1 000.00'), findsWidgets);
        expect(find.text('R 14 000.00 to go'), findsOneWidget);
        expect(
          find.textContaining('about 28 months (around Feb 2029)'),
          findsOneWidget,
        );
      });

  testWidgets('a bad amount shows the standard message', (tester) async {
    await _pumpPage(tester);

    await tester.enterText(find.byKey(const Key('fundDepositField')), 'abc');
    await tester.tap(find.byKey(const Key('addDepositButton')));
    await tester.pump();

    expect(
      find.text('Enter a valid amount, like 250 or 12.50'),
      findsOneWidget,
    );
  });
}