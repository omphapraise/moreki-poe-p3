import 'dart:convert';

/// How a saved answer should sound. Calm answers never get jokes.
enum CoachTone { calm, playful }

/// How far a saved answer has been fact-checked.
enum CoachStatus { verified, partiallyVerified, unverified, generalGuidance }

List<String> _strings(Object? value) =>
    (value as List<dynamic>).cast<String>().toList(growable: false);

CoachTone _toneFrom(String value) {
  switch (value) {
    case 'calm':
      return CoachTone.calm;
    case 'playful':
      return CoachTone.playful;
  }
  throw FormatException('Unknown coach tone: $value');
}

CoachStatus _statusFrom(String value) {
  switch (value) {
    case 'verified':
      return CoachStatus.verified;
    case 'partially_verified':
      return CoachStatus.partiallyVerified;
    case 'unverified':
      return CoachStatus.unverified;
    case 'general_guidance':
      return CoachStatus.generalGuidance;
  }
  throw FormatException('Unknown coach status: $value');
}

class CoachTopic {
  const CoachTopic({required this.id, required this.label});

  factory CoachTopic.fromJson(Map<String, dynamic> json) => CoachTopic(
    id: json['id'] as String,
    label: json['label'] as String,
  );

  final String id;
  final String label;
}

class CoachSource {
  const CoachSource({
    required this.title,
    required this.urls,
    required this.checkedOn,
    required this.note,
  });

  factory CoachSource.fromJson(Map<String, dynamic> json) => CoachSource(
    title: json['title'] as String,
    urls: _strings(json['urls']),
    checkedOn: json['checkedOn'] as String,
    note: json['note'] as String,
  );

  final String title;
  final List<String> urls;
  final String checkedOn;
  final String note;
}

class CoachEntry {
  const CoachEntry({
    required this.id,
    required this.topic,
    required this.tone,
    required this.questions,
    required this.keywords,
    required this.answer,
    required this.status,
    required this.sourceIds,
    this.nextStep,
    this.verifiedOn,
    this.openFeature,
  });

  factory CoachEntry.fromJson(Map<String, dynamic> json) => CoachEntry(
    id: json['id'] as String,
    topic: json['topic'] as String,
    tone: _toneFrom(json['tone'] as String),
    questions: _strings(json['questions']),
    keywords: _strings(json['keywords']),
    answer: json['answer'] as String,
    nextStep: json['nextStep'] as String?,
    status: _statusFrom(json['status'] as String),
    verifiedOn: json['verifiedOn'] as String?,
    sourceIds: _strings(json['sourceIds']),
    openFeature: json['openFeature'] as String?,
  );

  final String id;
  final String topic;
  final CoachTone tone;
  final List<String> questions;
  final List<String> keywords;
  final String answer;
  final String? nextStep;
  final CoachStatus status;
  final String? verifiedOn;
  final List<String> sourceIds;

  /// Name of the feature this answer can open (null if none).
  final String? openFeature;
}

class CoachData {
  const CoachData({
    required this.language,
    required this.disclaimer,
    required this.noMatchMessage,
    required this.topics,
    required this.sources,
    required this.entries,
    required this.playfulLines,
  });

  factory CoachData.fromJson(Map<String, dynamic> json) {
    final sourcesJson = json['sources'] as Map<String, dynamic>;
    return CoachData(
      language: json['language'] as String,
      disclaimer: json['disclaimer'] as String,
      noMatchMessage: json['noMatchMessage'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((t) => CoachTopic.fromJson(t as Map<String, dynamic>))
          .toList(growable: false),
      sources: {
        for (final item in sourcesJson.entries)
          item.key: CoachSource.fromJson(item.value as Map<String, dynamic>),
      },
      entries: (json['entries'] as List<dynamic>)
          .map((e) => CoachEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      playfulLines: _strings(json['playfulLines']),
    );
  }

  factory CoachData.fromJsonString(String source) =>
      CoachData.fromJson(jsonDecode(source) as Map<String, dynamic>);

  final String language;
  final String disclaimer;
  final String noMatchMessage;
  final List<CoachTopic> topics;
  final Map<String, CoachSource> sources;
  final List<CoachEntry> entries;
  final List<String> playfulLines;

  List<CoachEntry> entriesForTopic(String topicId) =>
      entries.where((e) => e.topic == topicId).toList(growable: false);
}