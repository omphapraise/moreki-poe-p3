import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/format/money_parts.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/money/presentation/money_page.dart';

Future<MoneyController> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final controller = MoneyController();
  addTearDown(controller.dispose);
  controller.setBudgetCents(8000000);
  controller.addExpense(
    amountCents: 2200000,
    category: ExpenseCategory.transport,
  );
  controller.addExpense(amountCents: 100000, category: ExpenseCategory.food);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: MoneyPage(controller: controller)),
  ));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets('deleting from Recent expenses removes it and Undo restores it',
          (tester) async {
        final c = await _pump(tester);
        final transport =
        c.expenses.firstWhere((e) => e.category == ExpenseCategory.transport);
        final transportLabel = categoryLabel(ExpenseCategory.transport);
        expect(find.text(transportLabel), findsOneWidget);

        await tester.tap(find.byKey(ValueKey('deleteExpense_${transport.id}')));
        await tester.pumpAndSettle();

        expect(c.expenses.length, 1);
        expect(find.text(transportLabel), findsNothing);
        expect(find.text('Expense deleted'), findsOneWidget);

        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        expect(c.expenses.length, 2);
        expect(find.text(transportLabel), findsOneWidget);
      });

  testWidgets('deleting from the Expenses tab works too', (tester) async {
    final c = await _pump(tester);
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    final food =
    c.expenses.firstWhere((e) => e.category == ExpenseCategory.food);
    await tester.tap(find.byKey(ValueKey('deleteExpense_${food.id}')));
    await tester.pumpAndSettle();

    expect(c.expenses.length, 1);
    expect(find.text('Expense deleted'), findsOneWidget);
  });

  testWidgets('the hero shows the cents small, as its own text',
          (tester) async {
        final c = await _pump(tester);
        final parts = splitRandForDisplay(formatRand(c.summary.remainingCents));

        expect(parts.cents, isNotNull);
        expect(find.text(parts.whole), findsOneWidget);
        expect(find.text(parts.cents!), findsOneWidget);
      });

  testWidgets('money fields always show the R and a floating label',
          (tester) async {
        await _pump(tester);

        for (final key in const ['budgetField', 'amountField']) {
          final field = tester.widget<TextField>(find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(TextField),
          ));
          expect(field.decoration!.prefixText, 'R ');
          expect(
            field.decoration!.floatingLabelBehavior,
            FloatingLabelBehavior.always,
          );
        }
      });
}