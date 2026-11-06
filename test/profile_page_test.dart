import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/profile/application/profile_controller.dart';
import 'package:moreki/features/profile/data/profile_store.dart';
import 'package:moreki/features/profile/domain/profile.dart';
import 'package:moreki/features/profile/presentation/profile_page.dart';

class _MemoryStore implements ProfileStore {
  ProfileSettings stored = const ProfileSettings();

  @override
  Future<ProfileSettings> load() async => stored;

  @override
  Future<void> save(ProfileSettings settings) async {
    stored = settings;
  }
}

Future<ProfileController> _pumpPage(
    WidgetTester tester, {
      _MemoryStore? store,
      bool loadFirst = true,
    }) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final controller = ProfileController(
    store: store ?? _MemoryStore(),
    clock: () => DateTime(2026, 10, 29),
  );
  addTearDown(controller.dispose);
  if (loadFirst) await controller.load();

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: ProfilePage(controller: controller)),
    ),
  );
  return controller;
}

void main() {
  testWidgets('shows a plain title when no name is set', (tester) async {
    await _pumpPage(tester);
    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Next payday'), findsNothing);
  });

  testWidgets('saving a name and payday shows the greeting and next payday',
          (tester) async {
        await _pumpPage(tester);

        await tester.enterText(find.byKey(const Key('profileNameField')), 'Ompha');
        await tester.enterText(find.byKey(const Key('profilePaydayField')), '25');
        await tester.tap(find.byKey(const Key('saveProfileButton')));
        await tester.pumpAndSettle();

        expect(find.text('Hi, Ompha'), findsOneWidget);
        expect(find.text('Next payday'), findsOneWidget);
        expect(find.text('25 Nov 2026'), findsOneWidget);
        expect(find.text('27 days'), findsOneWidget);
      });

  testWidgets('a bad payday shows a message and saves nothing',
          (tester) async {
        final controller = await _pumpPage(tester);

        await tester.enterText(find.byKey(const Key('profilePaydayField')), '40');
        await tester.tap(find.byKey(const Key('saveProfileButton')));
        await tester.pumpAndSettle();

        expect(find.text('Enter a day from 1 to 31'), findsOneWidget);
        expect(controller.settings.paydayDay, isNull);
      });

  testWidgets('picking a language saves it', (tester) async {
    final controller = await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('language_fr')));
    await tester.pumpAndSettle();

    expect(controller.settings.languageCode, 'fr');
  });

  testWidgets('saved details fill the fields once they have loaded',
          (tester) async {
        final store = _MemoryStore()
          ..stored = const ProfileSettings(displayName: 'Ompha', paydayDay: 25);

        // The page opens BEFORE the data has been read, like at app start.
        final controller = await _pumpPage(tester, store: store, loadFirst: false);
        expect(find.text('Your profile'), findsOneWidget);

        await controller.load();
        await tester.pumpAndSettle();

        expect(find.text('Hi, Ompha'), findsOneWidget);
        expect(find.text('27 days'), findsOneWidget);
      });
}