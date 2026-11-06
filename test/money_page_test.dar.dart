import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:moreki/features/money/presentation/money_page.dart';

Future<MoneyController> _pumpPage(
    WidgetTester tester, {
      MoneyController? controller,
    }) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final c = controller ?? MoneyController();
  addTearDown(c.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: MoneyPage(controller: c)),
    ),
  );
  return c;
}

void main() {
  testWidgets('asks for a budget when none is set', (tester) async {
    await _pumpPage(tester);
    expect(
      find.text('Set a monthly budget to see what is left.'),
      findsOneWidget,
    );
  });

  testWidgets('saving a budget then adding an expense updates what is left',
          (tester) async {
        await _pumpPage(tester);

        await tester.enterText(find.byKey(const Key('budgetField')), '1000');
        await tester.tap(find.byKey(const Key('saveBudgetButton')));
        await tester.pump();
        expect(find.text('R 0.00 of R 1 000.00 spent this month'), findsOneWidget);

        await tester.enterText(find.byKey(const Key('amountField')), '250');
        await tester.tap(find.byKey(const Key('addExpenseButton')));
        await tester.pump();

        expect(find.text('R 750.00'), findsOneWidget); // left to spend
        expect(find.text('R 250.00'), findsOneWidget); // the expense row
        expect(
          find.text('R 250.00 of R 1 000.00 spent this month'),
          findsOneWidget,
        );
      });

  testWidgets('a bad amount shows the standard message', (tester) async {
    await _pumpPage(tester);

    await tester.enterText(find.byKey(const Key('amountField')), 'abc');
    await tester.tap(find.byKey(const Key('addExpenseButton')));
    await tester.pump();

    expect(
      find.text('Enter a valid amount, like 250 or 12.50'),
      findsOneWidget,
    );
  });

  testWidgets('a picked date is saved with the expense', (tester) async {
    final c = await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('expenseDateButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('amountField')), '100');
    await tester.tap(find.byKey(const Key('addExpenseButton')));
    await tester.pump();

    expect(c.expenses.length, 1);
    expect(c.expenses.single.date.day, 1);
  });

  testWidgets('the Expenses tab lists newest date first', (tester) async {
    final now = DateTime.now();
    final c = MoneyController(budgetCents: 100000);
    await c.addExpense(
      amountCents: 1000,
      category: ExpenseCategory.food,
      date: now.subtract(const Duration(days: 10)),
    );
    await c.addExpense(
      amountCents: 2000,
      category: ExpenseCategory.rent,
      date: now,
    );
    await c.addExpense(
      amountCents: 3000,
      category: ExpenseCategory.transport,
      date: now.subtract(const Duration(days: 5)),
    );

    await _pumpPage(tester, controller: c);
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    final rent = tester.getTopLeft(find.text('Rent')).dy;
    final transport =
        tester.getTopLeft(find.text('Transport (taxi, bus, petrol)')).dy;
    final food = tester.getTopLeft(find.text('Food and groceries')).dy;

    expect(rent, lessThan(transport));
    expect(transport, lessThan(food));
  });

  testWidgets('Overview shows only 3 recent expenses and a link to all',
          (tester) async {
        final c = MoneyController(budgetCents: 100000);
        for (var i = 1; i <= 4; i++) {
          await c.addExpense(
            amountCents: i * 1000,
            category: ExpenseCategory.other,
          );
        }

        await _pumpPage(tester, controller: c);

        expect(find.byKey(const Key('seeAllExpensesButton')), findsOneWidget);
        expect(find.text('See all 4 expenses'), findsOneWidget);

        await tester.tap(find.byKey(const Key('seeAllExpensesButton')));
        await tester.pumpAndSettle();

        expect(find.text('All expenses'), findsOneWidget);
        expect(find.text('R 10.00'), findsOneWidget);
        expect(find.text('R 40.00'), findsOneWidget);
      });
}