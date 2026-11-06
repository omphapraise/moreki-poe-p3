import 'package:flutter/foundation.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/widget/data/widget_updater.dart';
import 'package:moreki/features/widget/domain/widget_snapshot.dart';

/// Wraps the real money store. Whenever money data is loaded or saved, it
/// also refreshes the home-screen widget. If the widget can't be updated,
/// the user's data is still saved and the app carries on.
class WidgetSyncingMoneyStore implements MoneyStore {
  WidgetSyncingMoneyStore({
    required MoneyStore inner,
    required WidgetUpdater updater,
    DateTime Function()? clock,
  })  : _inner = inner,
        _updater = updater,
        _clock = clock ?? DateTime.now;

  final MoneyStore _inner;
  final WidgetUpdater _updater;
  final DateTime Function() _clock;

  @override
  Future<MoneyData> load() async {
    final data = await _inner.load();
    await _refreshWidget(data);
    return data;
  }

  @override
  Future<void> save(MoneyData data) async {
    await _inner.save(data);
    await _refreshWidget(data);
  }

  Future<void> _refreshWidget(MoneyData data) async {
    try {
      await _updater.update(
        WidgetSnapshot.fromMoney(
          budgetCents: data.budgetCents,
          expenses: data.expenses,
          now: _clock(),
        ),
      );
    } catch (_) {
      // Never print the data itself, only that the widget failed.
      debugPrint('Moreki: could not update the home-screen widget');
    }
  }
}