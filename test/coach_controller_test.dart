import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/coach/application/coach_controller.dart';
import 'package:moreki/features/coach/data/coach_repository.dart';
import 'package:moreki/features/coach/domain/coach_models.dart';

String _json() => jsonEncode({
  'version': 1,
  'language': 'en',
  'createdOn': '2026-10-26',
  'disclaimer': 'Saved answers. Not live AI.',
  'noMatchMessage': 'No saved answer yet.',
  'statusMeanings': <String, String>{},
  'topics': [
    {'id': 'money', 'label': 'Money basics'},
    {'id': 'credit', 'label': 'Credit'},
  ],
  'sources': <String, dynamic>{},
  'playfulLines': ['Line A', 'Line B'],
  'guardrails': <String>[],
  'entries': [
    {
      'id': 'budget_basics',
      'topic': 'money',
      'tone': 'calm',
      'questions': ['How do I make a budget?'],
      'keywords': ['budget'],
      'answer': 'Write down what comes in and what goes out.',
      'nextStep': 'Try the Money tab.',
      'status': 'verified',
      'verifiedOn': '2026-10-01',
      'sourceIds': <String>[],
      'openFeature': 'money',
    },
    {
      'id': 'credit_score_chat',
      'topic': 'credit',
      'tone': 'playful',
      'questions': ['What is a credit score?'],
      'keywords': ['credit score'],
      'answer': 'A number that summarises how you handle credit.',
      'nextStep': null,
      'status': 'general_guidance',
      'verifiedOn': null,
      'sourceIds': <String>[],
      'openFeature': null,
    },
  ],
});

class _FakeRepository implements CoachRepository {
  _FakeRepository({this.fail = false});

  final bool fail;

  @override
  Future<CoachData> load() async {
    if (fail) throw Exception('could not load');
    return CoachData.fromJsonString(_json());
  }
}

CoachController _controller({bool fail = false}) {
  final controller = CoachController(repository: _FakeRepository(fail: fail));
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  test('starts in the loading state with no data', () {
    final controller = _controller();
    expect(controller.state, CoachLoadState.loading);
    expect(controller.data, isNull);
  });

  test('becomes ready after loading and tells listeners', () async {
    final controller = _controller();
    var calls = 0;
    controller.addListener(() => calls++);
    await controller.load();
    expect(controller.state, CoachLoadState.ready);
    expect(controller.data, isNotNull);
    expect(calls, greaterThanOrEqualTo(2));
  });

  test('goes to the error state when loading fails', () async {
    final controller = _controller(fail: true);
    await controller.load();
    expect(controller.state, CoachLoadState.error);
    expect(controller.data, isNull);
  });

  test('asking a saved question finds its answer', () async {
    final controller = _controller();
    await controller.load();
    controller.ask('How do I make a budget?');
    expect(controller.match?.best?.id, 'budget_basics');
    expect(controller.query, 'How do I make a budget?');
  });

  test('asking nonsense gives no match but offers topics', () async {
    final controller = _controller();
    await controller.load();
    controller.ask('xyzzy plugh');
    expect(controller.match?.hasMatch, isFalse);
    expect(controller.match?.suggestedTopics, isNotEmpty);
  });

  test('asking an empty question clears the answer', () async {
    final controller = _controller();
    await controller.load();
    controller.ask('How do I make a budget?');
    controller.ask('   ');
    expect(controller.match, isNull);
    expect(controller.query, '');
  });

  test('asking before the answers have loaded does not crash', () {
    final controller = _controller();
    controller.ask('How do I make a budget?');
    expect(controller.match, isNull);
  });

  test('choosing a topic lists its answers; choosing it again clears it',
          () async {
        final controller = _controller();
        await controller.load();
        controller.selectTopic('money');
        expect(controller.selectedTopicId, 'money');
        expect(controller.entriesInSelectedTopic.length, 1);
        controller.selectTopic('money');
        expect(controller.selectedTopicId, isNull);
        expect(controller.entriesInSelectedTopic, isEmpty);
      });

  test('calm answers get no joke opener, playful ones always the same one',
          () async {
        final controller = _controller();
        await controller.load();
        final calm = controller.data!.entries.firstWhere((e) => e.id == 'budget_basics');
        final playful =
        controller.data!.entries.firstWhere((e) => e.id == 'credit_score_chat');
        expect(controller.openerFor(calm), isNull);
        final first = controller.openerFor(playful);
        expect(['Line A', 'Line B'], contains(first));
        expect(controller.openerFor(playful), first);
      });

  test('clearAnswer empties the current answer', () async {
    final controller = _controller();
    await controller.load();
    controller.ask('How do I make a budget?');
    controller.clearAnswer();
    expect(controller.match, isNull);
  });
}