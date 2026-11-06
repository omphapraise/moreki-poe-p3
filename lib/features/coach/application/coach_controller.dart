import 'package:flutter/foundation.dart';
import 'package:moreki/features/coach/data/coach_repository.dart';
import 'package:moreki/features/coach/domain/coach_matcher.dart';
import 'package:moreki/features/coach/domain/coach_models.dart';

enum CoachLoadState { loading, ready, error }

/// Holds what the Coach screen needs: the saved answers, the chosen topic,
/// what was typed and the answer that was found. No UI code in here.
class CoachController extends ChangeNotifier {
  CoachController({required CoachRepository repository})
      : _repository = repository;

  final CoachRepository _repository;

  CoachData? _data;
  CoachMatcher? _matcher;
  CoachLoadState _state = CoachLoadState.loading;
  String? _selectedTopicId;
  String _query = '';
  CoachMatch? _match;
  bool _disposed = false;

  CoachLoadState get state => _state;
  CoachData? get data => _data;
  String? get selectedTopicId => _selectedTopicId;

  /// The text of the last question asked (empty if none).
  String get query => _query;

  /// The answer found for the last question (null if none asked yet).
  CoachMatch? get match => _match;

  /// Saved answers in the chosen topic (empty if no topic is chosen).
  List<CoachEntry> get entriesInSelectedTopic {
    final data = _data;
    final id = _selectedTopicId;
    if (data == null || id == null) return const <CoachEntry>[];
    return data.entriesForTopic(id);
  }

  Future<void> load() async {
    _state = CoachLoadState.loading;
    _notify();
    try {
      final data = await _repository.load();
      _data = data;
      _matcher = CoachMatcher(data);
      _state = CoachLoadState.ready;
    } catch (error) {
      debugPrint('Moreki: coach answers could not be loaded: $error');
      _data = null;
      _matcher = null;
      _state = CoachLoadState.error;
    }
    _notify();
  }

  /// Tapping the chosen topic again un-chooses it.
  void selectTopic(String? topicId) {
    _selectedTopicId = topicId == _selectedTopicId ? null : topicId;
    _notify();
  }

  /// Looks up an answer for what the person typed or tapped.
  void ask(String text) {
    final matcher = _matcher;
    if (matcher == null) return;
    final trimmed = text.trim();
    _query = trimmed;
    _match = trimmed.isEmpty ? null : matcher.find(trimmed);
    _notify();
  }

  /// Opens a specific saved answer (used for "related" answers).
  void askEntry(CoachEntry entry) {
    if (entry.questions.isEmpty) {
      _query = '';
      _match = CoachMatch(best: entry);
      _notify();
      return;
    }
    ask(entry.questions.first);
  }

  void clearAnswer() {
    _query = '';
    _match = null;
    _notify();
  }

  /// A joke opener for playful answers only. Calm answers always get null.
  /// The same answer always gets the same line (no randomness).
  String? openerFor(CoachEntry entry) {
    final lines = _data?.playfulLines ?? const <String>[];
    if (entry.tone != CoachTone.playful || lines.isEmpty) return null;
    final seed = entry.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return lines[seed % lines.length];
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}