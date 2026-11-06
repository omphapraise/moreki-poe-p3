import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/main.dart';

void main() {
      testWidgets('set a budget, add an expense, and reject a bad amount',
              (tester) async {
                // A tall virtual screen so everything is visible without scrolling.
                tester.view.physicalSize = const Size(1080, 2400);
                tester.view.devicePixelRatio = 1.0;
                addTearDown(tester.view.reset);

                await tester.pumpWidget(const MorekiApp());
                // Home is showing (the wordmark sits in the top bar).
                expect(find.text('moreki'), findsOneWidget);

                await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
                await tester.pumpAndSettle();

                await tester.enterText(find.byKey(const Key('budgetField')), '1000');
                await tester.tap(find.byKey(const Key('saveBudgetButton')));
                await tester.pump();

                await tester.enterText(find.byKey(const Key('amountField')), '250');
                await tester.tap(find.byKey(const Key('addExpenseButton')));
                await tester.pump();

                expect(find.text('R 250.00'), findsOneWidget);

                await tester.enterText(find.byKey(const Key('amountField')), 'abc');
                await tester.tap(find.byKey(const Key('addExpenseButton')));
                await tester.pump();

                expect(find.text('Enter a valid amount, like 250 or 12.50'),
                    findsOneWidget);
          });
}