import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the family contribution numbers are kept. The app only talks to
/// this interface, so it can move to Firebase later without touching screens.
abstract class FamilyContributionStore {
  Future<FamilyContributionPlan> load();
  Future<void> save(FamilyContributionPlan plan);
}

/// Saves the numbers on the phone as one block of JSON.
/// NOTE: one slot per device for now; it becomes per-user once login exists.
class SharedPrefsFamilyContributionStore implements FamilyContributionStore {
  static const _key = 'moreki_family_contribution_v1';

  @override
  Future<FamilyContributionPlan> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const FamilyContributionPlan();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final takeHome = map['takeHomeCents'] as int;
      final essentials = map['essentialsCents'] as int;
      final savings = map['savingsCents'] as int;
      final requested = map['requestedCents'] as int;
      if (takeHome < 0 || essentials < 0 || savings < 0 || requested < 0) {
        throw const FormatException('negative amount');
      }
      return FamilyContributionPlan(
        takeHomeCents: takeHome,
        essentialsCents: essentials,
        savingsCents: savings,
        requestedCents: requested,
      );
    } catch (_) {
      // Damaged data: start fresh instead of crashing. We never print the
      // data itself, only that it failed.
      debugPrint('Moreki: saved family contribution data could not be read');
      return const FamilyContributionPlan();
    }
  }

  @override
  Future<void> save(FamilyContributionPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'takeHomeCents': plan.takeHomeCents,
      'essentialsCents': plan.essentialsCents,
      'savingsCents': plan.savingsCents,
      'requestedCents': plan.requestedCents,
    });
    await prefs.setString(_key, json);
  }
}