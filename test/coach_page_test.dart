import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/coach/application/coach_controller.dart';
import 'package:moreki/features/coach/data/coach_repository.dart';
import 'package:moreki/features/coach/domain/coach_models.dart';
import 'package:moreki/features/coach/presentation/coach_page.dart';

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
      'answer': 'Write down what comes in.\n\nThen write down what goes out.',
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

Future<CoachController> _pumpPage(
    WidgetTester tester, {
      bool fail = false,
      bool load = true,
      Set<String> available = const <String>{},
      ValueChanged<String>? onOpen,
    }) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final controller = CoachController(repository: _FakeRepository(fail: fail));
  addTearDown(controller.dispose);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark(),
    home: CoachPage(
      controller: controller,
      availableFeatures: available,
      onOpenFeature: onOpen,
    ),
  ));
  if (load) {
    controller.load();
    await tester.pumpAndSettle();
  }
  return controller;
}

Future<void> _type(WidgetTester tester, String question) async {
  await tester.enterText(find.byType(TextField), question);
  await tester.tap(find.byIcon(Icons.send_rounded));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows a spinner while the answers are loading', (tester) async {
    await _pumpPage(tester, load: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the disclaimer and the topics once loaded',
          (tester) async {
        await _pumpPage(tester);
        expect(find.text('Saved answers. Not live AI.'), findsOneWidget);
        expect(find.text('Money basics'), findsOneWidget);
        expect(find.text('Credit'), findsOneWidget);
      });

  testWidgets('a typed question shows the answer, status and next step',
          (tester) async {
        await _pumpPage(tester);
        await _type(tester, 'How do I make a budget?');
        expect(find.text('Write down what comes in.'), findsOneWidget);
        expect(find.text('Then write down what goes out.'), findsOneWidget);
        expect(find.textContaining('Verified'), findsOneWidget);
        expect(find.text('Try the Money tab.'), findsOneWidget);
        expect(find.text('Line A'), findsNothing);
        expect(find.text('Line B'), findsNothing);
      });

  testWidgets('choosing a topic lists its questions and tapping one answers',
          (tester) async {
        await _pumpPage(tester);
        expect(find.text('How do I make a budget?'), findsNothing);
        await tester.tap(find.text('Money basics'));
        await tester.pumpAndSettle();
        expect(find.text('How do I make a budget?'), findsOneWidget);
        await tester.tap(find.text('How do I make a budget?'));
        await tester.pumpAndSettle();
        expect(find.text('Write down what comes in.'), findsOneWidget);
      });

  testWidgets('a question with no saved answer says so honestly',
          (tester) async {
        await _pumpPage(tester);
        await _type(tester, 'xyzzy plugh');
        expect(find.text('No saved answer yet.'), findsOneWidget);
        expect(find.textContaining('Pick a topic'), findsOneWidget);
      });

  testWidgets('shows an Open button for a real feature and reports the tap',
          (tester) async {
        String? opened;
        await _pumpPage(
          tester,
          available: const {'money'},
          onOpen: (feature) => opened = feature,
        );
        await _type(tester, 'How do I make a budget?');
        expect(find.text('Open Money'), findsOneWidget);
        await tester.tap(find.text('Open Money'));
        expect(opened, 'money');
      });

  testWidgets('hides the Open button when the feature is not built yet',
          (tester) async {
        await _pumpPage(tester);
        await _type(tester, 'How do I make a budget?');
        expect(find.text('Open Money'), findsNothing);
      });

  testWidgets('a playful answer gets exactly one opener line and its label',
          (tester) async {
        await _pumpPage(tester);
        await _type(tester, 'What is a credit score?');
        final lineA = find.text('Line A').evaluate().length;
        final lineB = find.text('Line B').evaluate().length;
        expect(lineA + lineB, 1);
        expect(find.text('General guidance'), findsOneWidget);
      });

  testWidgets('shows an error with a Try again button when loading fails',
          (tester) async {
        await _pumpPage(tester, fail: true);
        expect(find.textContaining("couldn't load"), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
      });
}