import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/coach/domain/coach_models.dart';

const _allowedFeatures = <String>{
  'salaryDiagnosis',
  'creditScore',
  'taxReturn',
  'emergencyFund',
  'familyContribution',
  'sideHustle',
  'insuranceGuide',
  'crisisMode',
  'money',
};

void main() {
  final data = CoachData.fromJsonString(
    File('assets/coach/coach_en.json').readAsStringSync(),
  );
  final jokeWords = RegExp(
    r'\b(lol|haha|pal|clown|courtroom|plot twist)\b',
    caseSensitive: false,
  );
  final swearWords = RegExp(
    r'\b(shit|fuck|damn|hell|bitch|crap|arse|ass)\b',
    caseSensitive: false,
  );

  group('coach data', () {
    test('shows the honest disclaimer', () {
      expect(
        data.disclaimer,
        'Saved answers from Moreki. Not live AI. Not financial advice.',
      );
    });

    test('has plenty of entries', () {
      expect(data.entries.length, greaterThanOrEqualTo(50));
    });

    test('every entry has the required fields', () {
      for (final e in data.entries) {
        expect(e.id, isNotEmpty);
        expect(e.answer, isNotEmpty, reason: e.id);
        expect(e.questions, isNotEmpty, reason: e.id);
        expect(e.keywords, isNotEmpty, reason: e.id);
      }
    });

    test('entry ids are unique', () {
      final ids = data.entries.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every entry belongs to a real topic and every topic has entries', () {
      final topicIds = data.topics.map((t) => t.id).toSet();
      for (final e in data.entries) {
        expect(topicIds.contains(e.topic), isTrue, reason: e.id);
      }
      for (final t in data.topics) {
        expect(data.entriesForTopic(t.id), isNotEmpty, reason: t.id);
      }
    });

    test('every source id resolves', () {
      for (final e in data.entries) {
        for (final s in e.sourceIds) {
          expect(data.sources.containsKey(s), isTrue, reason: '${e.id} -> $s');
        }
      }
    });

    test('only verified entries have a verified date, and they have sources',
            () {
          for (final e in data.entries) {
            if (e.status == CoachStatus.verified) {
              expect(e.verifiedOn, isNotNull, reason: e.id);
              expect(e.sourceIds, isNotEmpty, reason: e.id);
            } else {
              expect(e.verifiedOn, isNull, reason: e.id);
            }
          }
        });

    test('calm answers contain no jokes', () {
      for (final e in data.entries.where((e) => e.tone == CoachTone.calm)) {
        expect(jokeWords.hasMatch(e.answer), isFalse, reason: e.id);
      }
    });

    test('nothing swears', () {
      for (final e in data.entries) {
        expect(swearWords.hasMatch(e.answer), isFalse, reason: e.id);
      }
      for (final line in data.playfulLines) {
        expect(swearWords.hasMatch(line), isFalse, reason: line);
      }
    });

    test('openFeature names are known', () {
      for (final e in data.entries) {
        if (e.openFeature != null) {
          expect(_allowedFeatures.contains(e.openFeature), isTrue,
              reason: e.id);
        }
      }
    });

    test('the debt-hopeless answer keeps both help numbers', () {
      final entry = data.entries.firstWhere((e) => e.id == 'debt-hopeless');
      expect(entry.answer, contains('0800 567 567'));
      expect(entry.answer, contains('0860 627 627'));
    });
  });
}