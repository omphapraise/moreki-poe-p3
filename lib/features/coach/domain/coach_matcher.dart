import 'dart:math' as math;

import 'package:moreki/features/coach/domain/coach_models.dart';

/// The result of looking up a question.
class CoachMatch {
  const CoachMatch({
    this.best,
    this.related = const <CoachEntry>[],
    this.suggestedTopics = const <CoachTopic>[],
  });

  /// The best saved answer, or null when nothing fits well enough.
  final CoachEntry? best;

  /// Other saved answers that also fit (never includes [best]).
  final List<CoachEntry> related;

  /// Topics to offer when there is no match.
  final List<CoachTopic> suggestedTopics;

  bool get hasMatch => best != null;
}

class _Scored {
  const _Scored(this.entry, this.score);

  final CoachEntry entry;
  final double score;
}

/// Finds the saved answer that fits what the person typed.
/// Deterministic: the same text always gives the same result.
class CoachMatcher {
  CoachMatcher(this.data);

  final CoachData data;

  /// Below this score we say "no saved answer" instead of guessing.
  static const double minScore = 3.0;

  /// Score for typing a saved question word for word.
  static const double exactScore = 1000.0;

  static const int maxRelated = 3;

  static const Set<String> _stopWords = {
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'am', 'be', 'been', 'i',
    'im', 'ive', 'id', 'my', 'me', 'mine', 'to', 'of', 'and', 'or', 'in',
    'on', 'at', 'it', 'its', 'do', 'does', 'did', 'can', 'could', 'should',
    'would', 'will', 'how', 'what', 'whats', 'why', 'when', 'where', 'who',
    'which', 'if', 'for', 'with', 'so', 'that', 'this', 'these', 'those',
    'you', 'your', 'just', 'still', 'get', 'got', 'into', 'than', 'then',
    'them', 'they', 'we', 'our', 'us', 'there', 'here', 'as', 'by', 'from',
    'up', 'out', 'about', 'really', 'also', 'very',
  };

  /// Lowercase, drop apostrophes, replace everything that is not a letter
  /// or digit with a single space.
  static String normalise(String text) {
    final lower = text
        .toLowerCase()
        .replaceAll('\u2019', "'")
        .replaceAll('\u2018', "'")
        .replaceAll("'", '');
    return lower.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  /// Normalised words with the filler words removed.
  static List<String> tokens(String text) => normalise(text)
      .split(' ')
      .where((w) => w.isNotEmpty && !_stopWords.contains(w))
      .toList(growable: false);

  double scoreEntry(CoachEntry entry, String text) {
    final n = normalise(text);
    if (n.isEmpty) return 0;

    for (final q in entry.questions) {
      if (normalise(q) == n) return exactScore;
    }

    final padded = ' $n ';
    var score = 0.0;
    for (final k in entry.keywords) {
      final nk = normalise(k);
      if (nk.isNotEmpty && padded.contains(' $nk ')) {
        score += 2 * nk.split(' ').length + 1;
      }
    }

    final userTokens = tokens(text).toSet();
    var bestOverlap = 0.0;
    if (userTokens.isNotEmpty) {
      for (final q in entry.questions) {
        final questionTokens = tokens(q).toSet();
        if (questionTokens.isEmpty) continue;
        final shared = userTokens.intersection(questionTokens).length;
        if (shared < 2) continue;
        final value =
            shared / math.sqrt(userTokens.length * questionTokens.length) * 10;
        if (value > bestOverlap) bestOverlap = value;
      }
    }
    return score + bestOverlap;
  }

  CoachMatch find(String text) {
    final scored = <_Scored>[
      for (final e in data.entries) _Scored(e, scoreEntry(e, text)),
    ]..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.entry.id.compareTo(b.entry.id);
    });

    if (scored.isNotEmpty && scored.first.score >= minScore) {
      final related = scored
          .skip(1)
          .where((s) => s.score >= minScore)
          .take(maxRelated)
          .map((s) => s.entry)
          .toList(growable: false);
      return CoachMatch(best: scored.first.entry, related: related);
    }
    return CoachMatch(suggestedTopics: _suggestTopics(text, scored));
  }

  List<CoachTopic> _suggestTopics(String text, List<_Scored> scored) {
    final userTokens = tokens(text).toSet();
    final ids = <String>[];

    for (final topic in data.topics) {
      final labelTokens = tokens(topic.label).toSet();
      if (userTokens.intersection(labelTokens).isNotEmpty) ids.add(topic.id);
    }
    for (final s in scored) {
      if (s.score <= 0 || ids.length >= 3) break;
      if (!ids.contains(s.entry.topic)) ids.add(s.entry.topic);
    }

    final result = data.topics.where((t) => ids.contains(t.id)).toList();
    return result.isEmpty ? data.topics : result;
  }
}