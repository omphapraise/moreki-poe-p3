import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moreki/features/side_hustle/domain/side_hustle.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything we save about the side hustle.
class SideHustleData {
  const SideHustleData({this.entries = const []});

  final List<HustleEntry> entries;
}

/// Where the side hustle data is kept. The app only talks to this interface,
/// so it can move to Firebase later without touching screens.
abstract class SideHustleStore {
  Future<SideHustleData> load();
  Future<void> save(SideHustleData data);
}

/// Saves the data on the phone as one block of JSON.
/// NOTE: one slot per device for now; it becomes per-user once login exists.
class SharedPrefsSideHustleStore implements SideHustleStore {
  static const _key = 'moreki_side_hustle_v1';

  @override
  Future<SideHustleData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const SideHustleData();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entries = (map['entries'] as List<dynamic>)
          .map((e) => HustleEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      return SideHustleData(entries: entries);
    } catch (_) {
      // Damaged data: start fresh instead of crashing. We never print the
      // data itself, only that it failed.
      debugPrint('Moreki: saved side hustle data could not be read');
      return const SideHustleData();
    }
  }

  @override
  Future<void> save(SideHustleData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'entries': data.entries.map((e) => e.toJson()).toList(),
    });
    await prefs.setString(_key, json);
  }
}
