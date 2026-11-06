import 'package:flutter/foundation.dart';
import 'package:moreki/features/side_hustle/data/side_hustle_store.dart';
import 'package:moreki/features/side_hustle/domain/side_hustle.dart';

/// Holds the side hustle entries, and tells the screen when something
/// changes. If a store is given, changes are saved.
class SideHustleController extends ChangeNotifier {
  SideHustleController({
    SideHustleStore? store,
    DateTime Function()? clock,
  })  : _store = store,
        _clock = clock ?? DateTime.now;

  final SideHustleStore? _store;
  final DateTime Function() _clock;

  final List<HustleEntry> _entries = [];

  /// Newest first by date (ties keep the order they were added in, latest
  /// added first).
  List<HustleEntry> get entries {
    final indexed = _entries.asMap().entries.toList()
      ..sort((a, b) {
        final byDate = b.value.date.compareTo(a.value.date);
        return byDate != 0 ? byDate : b.key.compareTo(a.key);
      });
    return List.unmodifiable(indexed.map((e) => e.value));
  }

  /// Everything ever entered.
  HustleSummary get allTime => SideHustleCalculator.summarise(_entries);

  /// Only the current calendar month.
  HustleSummary get thisMonth =>
      SideHustleCalculator.summarise(_entries, month: _clock());

  /// Loads saved data (call once when the app starts).
  Future<void> load() async {
    final store = _store;
    if (store == null) return;
    try {
      final data = await store.load();
      _entries
        ..clear()
        ..addAll(data.entries);
      notifyListeners();
    } catch (_) {
      debugPrint('Moreki: could not load side hustle data');
    }
  }

  /// Adds income or a cost. Returns false (and changes nothing) if the
  /// amount is not above zero.
  Future<bool> addEntry({
    required HustleEntryType type,
    required int amountCents,
    String note = '',
    DateTime? date,
  }) async {
    if (amountCents <= 0) return false;
    final now = _clock();
    _entries.add(
      HustleEntry(
        id: '${now.microsecondsSinceEpoch}-${_entries.length}',
        type: type,
        amountCents: amountCents,
        date: date ?? now,
        note: note.trim(),
      ),
    );
    notifyListeners();
    await _persist();
    return true;
  }

  /// Puts back an entry that was just deleted (for Undo).
  Future<void> restoreEntry(HustleEntry entry) async {
    if (_entries.any((e) => e.id == entry.id)) return;
    _entries.add(entry);
    notifyListeners();
    await _persist();
  }

  /// Deletes one entry. Returns false if there is no entry with that id.
  Future<bool> deleteEntry(String id) async {
    final before = _entries.length;
    _entries.removeWhere((e) => e.id == id);
    if (_entries.length == before) return false;
    notifyListeners();
    await _persist();
    return true;
  }

  /// Deletes every entry and saves the empty state.
  Future<void> clearAll() async {
    _entries.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) return;
    try {
      await store.save(SideHustleData(entries: List.of(_entries)));
    } catch (_) {
      debugPrint('Moreki: could not save side hustle data');
    }
  }
}
