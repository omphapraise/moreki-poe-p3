import 'package:flutter/foundation.dart';
import 'package:moreki/features/profile/data/profile_store.dart';
import 'package:moreki/features/profile/domain/profile.dart';

/// Holds the profile and tells the screen when something changes.
/// If a store is given, changes are saved.
class ProfileController extends ChangeNotifier {
  ProfileController({ProfileStore? store, DateTime Function()? clock})
      : _store = store,
        _clock = clock ?? DateTime.now;

  final ProfileStore? _store;
  final DateTime Function() _clock;

  ProfileSettings _settings = const ProfileSettings();
  bool _loaded = false;

  ProfileSettings get settings => _settings;

  /// True once saved data has been read (or there is nothing to read).
  bool get loaded => _loaded;

  /// The next payday, or null if no payday is set.
  PaydayInfo? get payday {
    final day = _settings.paydayDay;
    return day == null ? null : PaydayCalculator.next(_clock(), day);
  }

  /// Loads saved data (call once when the app starts).
  Future<void> load() async {
    final store = _store;
    if (store == null) {
      _loaded = true;
      return;
    }
    try {
      _settings = await store.load();
    } catch (_) {
      debugPrint('Moreki: could not load profile');
    }
    _loaded = true;
    notifyListeners();
  }

  /// Saves the name and payday. Returns false (and changes nothing) if the
  /// name is too long or the payday is not 1 to 31.
  Future<bool> saveDetails({
    required String displayName,
    int? paydayDay,
  }) async {
    final name = displayName.trim();
    if (name.length > ProfileSettings.maxNameLength) return false;
    if (paydayDay != null && (paydayDay < 1 || paydayDay > 31)) return false;

    _settings = ProfileSettings(
      displayName: name,
      languageCode: _settings.languageCode,
      paydayDay: paydayDay,
    );
    notifyListeners();
    await _persist();
    return true;
  }

  /// Picks the language. Returns false for an unknown code.
  Future<bool> setLanguage(String code) async {
    if (!ProfileSettings.isSupportedLanguage(code)) return false;
    _settings = ProfileSettings(
      displayName: _settings.displayName,
      languageCode: code,
      paydayDay: _settings.paydayDay,
    );
    notifyListeners();
    await _persist();
    return true;
  }

  /// Deletes the name, payday and language choice (back to the defaults) and
  /// saves the empty state.
  Future<void> clearAll() async {
    _settings = const ProfileSettings();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) return;
    try {
      await store.save(_settings);
    } catch (_) {
      debugPrint('Moreki: could not save profile');
    }
  }
}