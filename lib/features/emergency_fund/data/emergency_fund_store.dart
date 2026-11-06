import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moreki/features/emergency_fund/domain/emergency_fund.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything we save about the emergency fund.
class EmergencyFundData {
  const EmergencyFundData({
    this.plan = const EmergencyFundPlan(),
    this.deposits = const [],
  });

  final EmergencyFundPlan plan;
  final List<FundDeposit> deposits;

  int get savedCents => deposits.fold<int>(0, (sum, d) => sum + d.amountCents);
}

/// Where the fund data is kept. The app only talks to this interface, so it
/// can move to Firebase later without touching screens.
abstract class EmergencyFundStore {
  Future<EmergencyFundData> load();
  Future<void> save(EmergencyFundData data);
}

/// Saves the data on the phone as one block of JSON.
/// NOTE: one slot per device for now; it becomes per-user once login exists.
class SharedPrefsEmergencyFundStore implements EmergencyFundStore {
  static const _key = 'moreki_emergency_fund_v1';

  @override
  Future<EmergencyFundData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const EmergencyFundData();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final months = map['targetMonths'] as int;
      return EmergencyFundData(
        plan: EmergencyFundPlan(
          essentialsCents: map['essentialsCents'] as int,
          targetMonths:
          EmergencyFundCalculator.targetOptions.contains(months) ? months : 3,
          monthlyContributionCents: map['monthlyContributionCents'] as int,
        ),
        deposits: (map['deposits'] as List<dynamic>)
            .map((d) => FundDeposit.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      // Damaged data: start fresh instead of crashing. We never print the
      // data itself, only that it failed.
      debugPrint('Moreki: saved emergency fund data could not be read');
      return const EmergencyFundData();
    }
  }

  @override
  Future<void> save(EmergencyFundData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'essentialsCents': data.plan.essentialsCents,
      'targetMonths': data.plan.targetMonths,
      'monthlyContributionCents': data.plan.monthlyContributionCents,
      'deposits': data.deposits.map((d) => d.toJson()).toList(),
    });
    await prefs.setString(_key, json);
  }
}