import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/side_hustle/application/side_hustle_controller.dart';
import 'package:moreki/features/side_hustle/presentation/side_hustle_page.dart';

void main() {
  Future<SideHustleController> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SideHustleController(
      clock: () => DateTime(2026, 11, 4, 12),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: SideHustlePage(controller: controller),
      ),
    );
    return controller;
  }

  testWidgets('shows the empty state first', (tester) async {
    await pump(tester);
    expect(find.text('Side hustle'), findsOneWidget);
    expect(
      find.text('Add income or a cost to see what you keep.'),
      findsOneWidget,
    );
    expect(
      find.text('Nothing yet. Add your first income or cost above.'),
      findsOneWidget,
    );
  });

  testWidgets('adding income and a cost shows what you keep', (tester) async {
    final controller = await pump(tester);

    await tester.enterText(
      find.byKey(const Key('sideHustleAmountField')),
      '1000',
    );
    await tester.tap(find.byKey(const Key('addSideHustleButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cost'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('sideHustleAmountField')),
      '250',
    );
    await tester.tap(find.byKey(const Key('addSideHustleButton')));
    await tester.pumpAndSettle();

    expect(controller.thisMonth.incomeCents, 100000);
    expect(controller.thisMonth.costCents, 25000);
    expect(controller.thisMonth.keepCents, 75000);
    expect(
      find.text('You keep about 75% of what you earn this month.'),
      findsOneWidget,
    );
  });

  testWidgets('a bad amount shows an error and saves nothing', (tester) async {
    final controller = await pump(tester);

    await tester.enterText(
      find.byKey(const Key('sideHustleAmountField')),
      'abc',
    );
    await tester.tap(find.byKey(const Key('addSideHustleButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid amount, like 250 or 12.50'),
      findsOneWidget,
    );
    expect(controller.entries, isEmpty);
  });
}
