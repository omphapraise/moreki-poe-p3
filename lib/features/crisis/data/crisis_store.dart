import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moreki/features/crisis/domain/crisis.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything we save for Crisis Mode.
class CrisisData {
  const CrisisData({this.plan = const CrisisPlan()});

  final CrisisPlan plan;
}

/// Where the Crisis Mode numbers are kept. The app only talks to this
/// interface, so it can move to Firebase later without touching screens.
abstract class CrisisStore {
  Future<CrisisData> load();
  Future<void> save(CrisisData data);
}

/// Saves the numbers on the phone as one block of JSON.
/// NOTE: one slot per device for now; it becomes per-user once login exists.
class SharedPrefsCrisisStore implements CrisisStore {
  static const _key = 'moreki_crisis_v1';

  @override
  Future<CrisisData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const CrisisData();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CrisisData(
        plan: CrisisPlan.fromJson(map['plan'] as Map<String, dynamic>),
      );
    } catch (_) {
      // Damaged data: start fresh instead of crashing. We never print the
      // data itself, only that it failed.
      debugPrint('Moreki: saved crisis data could not be read');
      return const CrisisData();
    }
  }

  @override
  Future<void> save(CrisisData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({'plan': data.plan.toJson()});
    await prefs.setString(_key, json);
  }
}
