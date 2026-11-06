import 'package:flutter/foundation.dart';
import 'package:moreki/features/emergency_fund/data/emergency_fund_store.dart';
import 'package:moreki/features/emergency_fund/domain/emergency_fund.dart';

/// Holds the emergency fund plan and savings, and tells the screen when
/// something changes. If a store is given, changes are saved.
class EmergencyFundController extends ChangeNotifier {
  EmergencyFundController({
    EmergencyFundStore? store,
    DateTime Function()? clock,
  })  : _store = store,
        _clock = clock ?? DateTime.now;

  final EmergencyFundStore? _store;
  final DateTime Function() _clock;

  EmergencyFundPlan _plan = const EmergencyFundPlan();
  final List<FundDeposit> _deposits = [];

  EmergencyFundPlan get plan => _plan;

  List<FundDeposit> get deposits => List.unmodifiable(_deposits);

  int get savedCents => _deposits.fold<int>(0, (sum, d) => sum + d.amountCents);

  FundProgress get progress => EmergencyFundCalculator.calculate(
    plan: _plan,
    savedCents: savedCents,
    today: _clock(),
  );

  /// Loads saved data (call once when the app starts).
  Future<void> load() async {
    final store = _store;
    if (store == null) return;
    try {
      final data = await store.load();
      _plan = data.plan;
      _deposits
        ..clear()
        ..addAll(data.deposits);
      notifyListeners();
    } catch (_) {
      debugPrint('Moreki: could not load emergency fund data');
    }
  }

  /// Saves the monthly essentials and monthly saving. Returns false (and
  /// changes nothing) if the numbers make no sense.
  Future<bool> savePlan({
    required int essentialsCents,
    required int monthlyContributionCents,
  }) async {
    if (essentialsCents <= 0 || monthlyContributionCents < 0) return false;
    _plan = _plan.copyWith(
      essentialsCents: essentialsCents,
      monthlyContributionCents: monthlyContributionCents,
    );
    notifyListeners();
    await _persist();
    return true;
  }

  /// Picks the goal length (1, 3 or 6 months).
  Future<bool> setTargetMonths(int months) async {
    if (!EmergencyFundCalculator.targetOptions.contains(months)) return false;
    _plan = _plan.copyWith(targetMonths: months);
    notifyListeners();
    await _persist();
    return true;
  }

  /// Adds money to the fund. Returns false if the amount is not above zero.
  Future<bool> addDeposit({required int amountCents, DateTime? date}) async {
    if (amountCents <= 0) return false;
    final now = _clock();
    _deposits.add(
      FundDeposit(
        id: '${now.microsecondsSinceEpoch}-${_deposits.length}',
        amountCents: amountCents,
        date: date ?? now,
      ),
    );
    notifyListeners();
    await _persist();
    return true;
  }

  /// Deletes the plan and every deposit, and saves the empty state.
  Future<void> clearAll() async {
    _plan = const EmergencyFundPlan();
    _deposits.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) return;
    try {
      await store.save(
        EmergencyFundData(plan: _plan, deposits: List.of(_deposits)),
      );
    } catch (_) {
      debugPrint('Moreki: could not save emergency fund data');
    }
  }
}