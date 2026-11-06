import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/family_contribution/application/family_contribution_controller.dart';
import 'package:moreki/features/family_contribution/data/family_contribution_store.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';
import 'package:moreki/features/family_contribution/presentation/family_contribution_page.dart';

class _MemoryStore implements FamilyContributionStore {
  FamilyContributionPlan stored = const FamilyContributionPlan();

  @override
  Future<FamilyContributionPlan> load() async => stored;

  @override
  Future<void> save(FamilyContributionPlan plan) async {
    stored = plan;
  }
}

Future<FamilyContributionController> _pumpPage(
    WidgetTester tester, {
      _MemoryStore? store,
    }) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final controller = FamilyContributionController(
    store: store ?? _MemoryStore(),
  );
  addTearDown(controller.dispose);
  await controller.load();

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: FamilyContributionPage(controller: controller),
    ),
  );
  return controller;
}

Future<void> _fill(
    WidgetTester tester, {
      String takeHome = '',
      String essentials = '',
      String savings = '',
      String requested = '',
    }) async {
  await tester.enterText(find.byKey(const Key('familyTakeHomeField')), takeHome);
  await tester.enterText(
    find.byKey(const Key('familyEssentialsField')),
    essentials,
  );
  await tester.enterText(find.byKey(const Key('familySavingsField')), savings);
  await tester.enterText(
    find.byKey(const Key('familyRequestedField')),
    requested,
  );
  await tester.tap(find.byKey(const Key('calculateFamilyButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('asks for numbers when nothing is set', (tester) async {
    await _pumpPage(tester);
    expect(
      find.text('Enter your numbers to see what is safe to send.'),
      findsOneWidget,
    );
  });

  testWidgets('calculating shows the safe amount and a comfortable verdict',
          (tester) async {
        await _pumpPage(tester);

        await _fill(
          tester,
          takeHome: '10000',
          essentials: '6000',
          savings: '1000',
          requested: '1500',
        );

        expect(find.text('R 2 000.00'), findsWidgets);
        expect(find.text('Comfortable'), findsOneWidget);
        expect(find.textContaining('R 1 500.00'), findsWidgets);
      });

  testWidgets('a request above the room says too much, kindly',
          (tester) async {
        await _pumpPage(tester);

        await _fill(
          tester,
          takeHome: '10000',
          essentials: '6000',
          savings: '1000',
          requested: '4000',
        );

        expect(find.text('Too much for now'), findsOneWidget);
        expect(find.textContaining('talk to your family'), findsOneWidget);
      });

  testWidgets('a bad amount shows the standard message', (tester) async {
    await _pumpPage(tester);

    await _fill(tester, takeHome: 'abc', essentials: '5000');

    expect(
      find.text('Enter a valid amount, like 250 or 12.50'),
      findsOneWidget,
    );
  });

  testWidgets('missing take-home asks for it', (tester) async {
    await _pumpPage(tester);

    await _fill(tester, essentials: '5000');

    expect(find.text('Enter your monthly take-home pay'), findsOneWidget);
  });

  testWidgets('saved numbers show up again when the page opens',
          (tester) async {
        final store = _MemoryStore()
          ..stored = const FamilyContributionPlan(
            takeHomeCents: 1000000,
            essentialsCents: 600000,
            savingsCents: 100000,
          );

        await _pumpPage(tester, store: store);

        expect(find.text('R 2 000.00'), findsWidgets);
        expect(find.text('Safe to send'), findsOneWidget);
      });
}