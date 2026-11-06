import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/coach/domain/coach_matcher.dart';
import 'package:moreki/features/coach/domain/coach_models.dart';

void main() {
  final data = CoachData.fromJsonString(
    File('assets/coach/coach_en.json').readAsStringSync(),
  );
  final matcher = CoachMatcher(data);

  group('normalise', () {
    test('lowercases and drops apostrophes and punctuation', () {
      expect(CoachMatcher.normalise("What's PAYE?!"), 'whats paye');
      expect(CoachMatcher.normalise('Don\u2019t   panic'), 'dont panic');
    });

    test('copes with emoji and empty text', () {
      expect(CoachMatcher.normalise('\u{1F480}'), '');
      expect(CoachMatcher.normalise(''), '');
    });
  });

  group('finding answers', () {
    test('every saved question finds its own answer', () {
      for (final e in data.entries) {
        for (final q in e.questions) {
          expect(matcher.find(q).best?.id, e.id, reason: q);
        }
      }
    });

    const paraphrases = <String, String>{
      'what is UIF': 'uif-what-is',
      'do I need funeral cover': 'insurance-funeral',
      'I have R300 left until payday': 'crisis-low-money',
      "what's a credit bureau": 'credit-what-bureau',
      'how much can I send my mom each month': 'family-how-much',
      'explain PAYE to me': 'paye-what-is',
      'is this a scam they say I will double my money': 'scam-double-money',
      'I have no fridge what can I buy': 'food-no-fridge',
      'are you a robot': 'about-ai',
      'can moreki lock my card': 'moreki-cant-lock',
      'how do i check my credit report': 'credit-check-report',
      'should i pay debt or save first': 'savings-or-debt-first',
      "i got paid and now i'm broke": 'payday-broke-fast',
      'what is gap cover': 'insurance-medical',
      "I don't understand my payslip": 'payslip-how-to-read',
      'i owe sars money': 'tax-pay-instalments',
      'do i have to tell you my salary': 'about-privacy',
    };

    paraphrases.forEach((question, expectedId) {
      test('"$question" finds $expectedId', () {
        expect(matcher.find(question).best?.id, expectedId);
      });
    });

    test('related answers never include the best one', () {
      final result = matcher.find("I don't understand my payslip");
      expect(result.related, isNotEmpty);
      expect(result.related.map((e) => e.id), isNot(contains(result.best!.id)));
    });

    test('the same text always gives the same answer', () {
      expect(
        matcher.find('where did my salary go').best?.id,
        matcher.find('where did my salary go').best?.id,
      );
    });
  });

  group('no saved answer', () {
    const nonsense = <String>[
      'blorp zibble quantum',
      "what's the weather today",
      'tell me a joke',
      '',
      '   ',
      '\u{1F480}',
    ];

    for (final text in nonsense) {
      test('"$text" is honest about not knowing', () {
        final result = matcher.find(text);
        expect(result.hasMatch, isFalse);
        expect(result.best, isNull);
        expect(result.suggestedTopics, isNotEmpty);
      });
    }

    test('a lone topic word suggests that topic', () {
      final result = matcher.find('tax');
      expect(result.hasMatch, isFalse);
      expect(result.suggestedTopics.map((t) => t.id), contains('tax'));
    });

    test('"salary" suggests the salary topic', () {
      final result = matcher.find('salary');
      expect(result.suggestedTopics.map((t) => t.id), contains('salary'));
    });
  });
}