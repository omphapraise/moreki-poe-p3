import 'package:flutter/foundation.dart';
import 'package:moreki/features/crisis/data/crisis_store.dart';
import 'package:moreki/features/crisis/domain/crisis.dart';

/// Holds the Crisis Mode numbers, and tells the screen when something
/// changes. If a store is given, changes are saved.
class CrisisController extends ChangeNotifier {
  CrisisController({CrisisStore? store}) : _store = store;

  final CrisisStore? _store;

  CrisisPlan _plan = const CrisisPlan();

  /// The numbers as typed in.
  CrisisPlan get plan => _plan;

  /// The worked-out picture for the current numbers.
  CrisisSummary get summary => CrisisCalculator.summarise(_plan);

  /// Loads saved data (call once when the app starts).
  Future<void> load() async {
    final store = _store;
    if (store == null) return;
    try {
      final data = await store.load();
      _plan = data.plan;
      notifyListeners();
    } catch (_) {
      debugPrint('Moreki: could not load crisis data');
    }
  }

  /// Saves new numbers. Returns false (and changes nothing) if any amount
  /// is negative.
  Future<bool> updatePlan(CrisisPlan plan) async {
    final all = [
      plan.incomeCents,
      plan.rentCents,
      plan.foodCents,
      plan.transportCents,
      plan.debtCents,
      plan.otherCents,
    ];
    if (all.any((v) => v < 0)) return false;
    _plan = plan;
    notifyListeners();
    await _persist();
    return true;
  }

  /// Clears every number and saves the empty state.
  Future<void> clearAll() async {
    _plan = const CrisisPlan();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) return;
    try {
      await store.save(CrisisData(plan: _plan));
    } catch (_) {
      debugPrint('Moreki: could not save crisis data');
    }
  }
}
