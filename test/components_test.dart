import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/core/widgets/bento_stats_card.dart';
import 'package:moreki/core/widgets/hero_number.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/core/widgets/pill_segmented_control.dart';
import 'package:moreki/core/widgets/progress_ring.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Align(alignment: Alignment.topCenter, child: child),
      ),
    ),
  );
}

void main() {
  test('clampProgress keeps values between 0 and 1', () {
    expect(clampProgress(1.7), 1.0);
    expect(clampProgress(-0.4), 0.0);
    expect(clampProgress(double.nan), 0.0);
    expect(clampProgress(0.5), 0.5);
  });

  testWidgets('HeroNumber shows the value, unit and uppercase label',
          (tester) async {
        await tester.pumpWidget(_wrap(const HeroNumber(
          value: 'R 4 750',
          unit: '.00',
          label: 'Left to spend',
        )));
        expect(find.text('R 4 750'), findsOneWidget);
        expect(find.text('.00'), findsOneWidget);
        expect(find.text('LEFT TO SPEND'), findsOneWidget);
      });

  testWidgets('PillSegmentedControl reports which segment was tapped',
          (tester) async {
        int? tapped;
        await tester.pumpWidget(_wrap(PillSegmentedControl(
          labels: const ['Overview', 'Spending'],
          selectedIndex: 0,
          onChanged: (i) => tapped = i,
        )));
        await tester.tap(find.text('Spending'));
        expect(tapped, 1);
      });

  testWidgets('ProgressRing survives values above 1 and shows its centre',
          (tester) async {
        await tester.pumpWidget(_wrap(const ProgressRing(
          value: 1.7,
          semanticsLabel: 'Budget used: 100 percent',
          center: Text('100'),
        )));
        await tester.pumpAndSettle();
        expect(find.text('100'), findsOneWidget);
      });

  testWidgets('BentoStatsCard shows every value and label', (tester) async {
    await tester.pumpWidget(_wrap(const BentoStatsCard(stats: [
      BentoStat(
        value: 'R 250.00',
        label: 'Spent this month',
        icon: Icons.receipt_long_rounded,
        tileColor: AppColors.tileYellow,
      ),
      BentoStat(
        value: 'R 5 000.00',
        label: 'Monthly budget',
        icon: Icons.flag_rounded,
        tileColor: AppColors.tileGreen,
      ),
    ])));
    expect(find.text('R 250.00'), findsOneWidget);
    expect(find.text('Spent this month'), findsOneWidget);
    expect(find.text('R 5 000.00'), findsOneWidget);
    expect(find.text('Monthly budget'), findsOneWidget);
  });

  testWidgets('MorekiDataRow shows its text and reacts to taps',
          (tester) async {
        var taps = 0;
        await tester.pumpWidget(_wrap(MorekiDataRow(
          title: 'Entertainment',
          subtitle: '24/10/2026',
          value: 'R 250.00',
          onTap: () => taps++,
        )));
        expect(find.text('Entertainment'), findsOneWidget);
        expect(find.text('R 250.00'), findsOneWidget);
        await tester.tap(find.text('Entertainment'));
        expect(taps, 1);
      });
}