import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/crisis/application/crisis_controller.dart';
import 'package:moreki/features/crisis/presentation/crisis_page.dart';

Future<CrisisController> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = CrisisController();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: CrisisPage(controller: controller),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<void> _type(WidgetTester tester, String key, String value) async {
  await tester.enterText(find.byKey(Key(key)), value);
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('saveCrisisButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the title and the empty caption', (tester) async {
    await _open(tester);
    expect(find.text('Crisis Mode'), findsOneWidget);
    expect(
      find.text('Add your income and essentials to see where you stand.'),
      findsOneWidget,
    );
    expect(find.text('Calm steps to take'), findsOneWidget);
  });

  testWidgets('saving income and rent shows the essentials percent',
      (tester) async {
    final c = await _open(tester);
    await _type(tester, 'crisisIncomeField', '10000');
    await _type(tester, 'crisisRentField', '4000');
    await _save(tester);

    expect(c.summary.leftCents, 600000);
    expect(
      find.text('Your essentials take about 40% of your income.'),
      findsOneWidget,
    );
    expect(find.text('Saved on this phone'), findsOneWidget);
  });

  testWidgets('shows the calm shortfall message when essentials are too much',
      (tester) async {
    final c = await _open(tester);
    await _type(tester, 'crisisIncomeField', '8000');
    await _type(tester, 'crisisRentField', '10000');
    await _save(tester);

    expect(c.summary.isShort, isTrue);
    expect(
      find.text(
        'Your essentials are more than your income. '
        'That is okay: the steps below can help.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('bad input shows an error and saves nothing', (tester) async {
    final c = await _open(tester);
    await _type(tester, 'crisisIncomeField', 'abc');
    await _save(tester);

    expect(find.text('Use numbers only, like 250 or 12.50'), findsOneWidget);
    expect(c.summary.hasData, isFalse);
  });
}
