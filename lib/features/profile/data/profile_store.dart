import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moreki/features/profile/domain/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the profile is kept. The app only talks to this interface, so it
/// can move to Firebase later without touching screens.
abstract class ProfileStore {
  Future<ProfileSettings> load();
  Future<void> save(ProfileSettings settings);
}

/// Saves the profile on the phone as one block of JSON.
/// NOTE: one slot per device for now; it becomes per-user once login exists.
class SharedPrefsProfileStore implements ProfileStore {
  static const _key = 'moreki_profile_v1';

  @override
  Future<ProfileSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const ProfileSettings();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      var name = (map['displayName'] as String).trim();
      if (name.length > ProfileSettings.maxNameLength) {
        name = name.substring(0, ProfileSettings.maxNameLength);
      }
      final language = map['languageCode'] as String;
      final payday = map['paydayDay'] as int?;
      return ProfileSettings(
        displayName: name,
        languageCode:
        ProfileSettings.isSupportedLanguage(language) ? language : 'en',
        paydayDay: (payday != null && payday >= 1 && payday <= 31)
            ? payday
            : null,
      );
    } catch (_) {
      // Damaged data: start fresh instead of crashing. We never print the
      // data itself, only that it failed.
      debugPrint('Moreki: saved profile could not be read');
      return const ProfileSettings();
    }
  }

  @override
  Future<void> save(ProfileSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'displayName': settings.displayName,
      'languageCode': settings.languageCode,
      'paydayDay': settings.paydayDay,
    });
    await prefs.setString(_key, json);
  }
}