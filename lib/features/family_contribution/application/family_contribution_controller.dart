import 'package:flutter/foundation.dart';
import 'package:moreki/features/family_contribution/data/family_contribution_store.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';

/// Holds the family contribution numbers and tells the screen when something
/// changes. If a store is given, changes are saved.
class FamilyContributionController extends ChangeNotifier {
  FamilyContributionController({FamilyContributionStore? store})
      : _store = store;

  final FamilyContributionStore? _store;

  FamilyContributionPlan _plan = const FamilyContributionPlan();

  FamilyContributionPlan get plan => _plan;

  /// True once a take-home amount has been saved.
  bool get hasPlan => _plan.takeHomeCents > 0;

  FamilyContributionResult get result =>
      FamilyContributionCalculator.calculate(_plan);

  /// Loads saved data (call once when the app starts).
  Future<void> load() async {
    final store = _store;
    if (store == null) return;
    try {
      _plan = await store.load();
      notifyListeners();
    } catch (_) {
      debugPrint('Moreki: could not load family contribution data');
    }
  }

  /// Saves the numbers. Returns false (and changes nothing) if they make no
  /// sense: take-home must be above zero, the rest can't be negative.
  Future<bool> savePlan({
    required int takeHomeCents,
    required int essentialsCents,
    int savingsCents = 0,
    int requestedCents = 0,
  }) async {
    if (takeHomeCents <= 0 ||
        essentialsCents < 0 ||
        savingsCents < 0 ||
        requestedCents < 0) {
      return false;
    }
    _plan = FamilyContributionPlan(
      takeHomeCents: takeHomeCents,
      essentialsCents: essentialsCents,
      savingsCents: savingsCents,
      requestedCents: requestedCents,
    );
    notifyListeners();
    await _persist();
    return true;
  }

  /// Deletes the numbers and saves the empty state.
  Future<void> clearAll() async {
    _plan = const FamilyContributionPlan();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) return;
    try {
      await store.save(_plan);
    } catch (_) {
      debugPrint('Moreki: could not save family contribution data');
    }
  }
}