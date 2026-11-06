import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/profile/data/profile_store.dart';
import 'package:moreki/features/profile/domain/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'moreki_profile_v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsProfileStore', () {
    test('loads defaults when nothing has been saved', () async {
      SharedPreferences.setMockInitialValues({});

      final s = await SharedPrefsProfileStore().load();

      expect(s.displayName, '');
      expect(s.languageCode, 'en');
      expect(s.paydayDay, isNull);
    });

    test('saves and loads every setting', () async {
      SharedPreferences.setMockInitialValues({});

      await SharedPrefsProfileStore().save(
        const ProfileSettings(
          displayName: 'Ompha',
          languageCode: 'af',
          paydayDay: 25,
        ),
      );

      final loaded = await SharedPrefsProfileStore().load();

      expect(loaded.displayName, 'Ompha');
      expect(loaded.languageCode, 'af');
      expect(loaded.paydayDay, 25);
    });

    test('French is saved and loaded', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPrefsProfileStore();

      await store.save(const ProfileSettings(languageCode: 'fr'));

      expect((await store.load()).languageCode, 'fr');
    });

    test('a payday of null is saved and loaded as null', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPrefsProfileStore();

      await store.save(const ProfileSettings(displayName: 'A', paydayDay: 5));
      await store.save(const ProfileSettings(displayName: 'A'));

      expect((await store.load()).paydayDay, isNull);
    });

    test('loads defaults instead of crashing when data is damaged', () async {
      SharedPreferences.setMockInitialValues({_key: 'not json {'});

      final s = await SharedPrefsProfileStore().load();

      expect(s.displayName, '');
      expect(s.languageCode, 'en');
    });

    test('loads defaults when saved JSON is missing fields', () async {
      SharedPreferences.setMockInitialValues({_key: '{}'});

      final s = await SharedPrefsProfileStore().load();

      expect(s.displayName, '');
    });

    test('an unknown language falls back to English', () async {
      SharedPreferences.setMockInitialValues({
        _key: jsonEncode({
          'displayName': 'Ompha',
          'languageCode': 'xx',
          'paydayDay': 25,
        }),
      });

      final s = await SharedPrefsProfileStore().load();

      expect(s.languageCode, 'en');
      expect(s.displayName, 'Ompha');
      expect(s.paydayDay, 25);
    });

    test('the cut languages (Tshivenda, siSwati) fall back to English',
        () async {
      for (final code in ['ve', 'ss']) {
        SharedPreferences.setMockInitialValues({
          _key: jsonEncode({
            'displayName': 'Ompha',
            'languageCode': code,
            'paydayDay': 25,
          }),
        });

        final s = await SharedPrefsProfileStore().load();

        expect(s.languageCode, 'en');
        expect(s.displayName, 'Ompha');
      }
    });

    test('a payday outside 1 to 31 is dropped', () async {
      SharedPreferences.setMockInitialValues({
        _key: jsonEncode({
          'displayName': 'Ompha',
          'languageCode': 'en',
          'paydayDay': 45,
        }),
      });

      final s = await SharedPrefsProfileStore().load();

      expect(s.paydayDay, isNull);
      expect(s.displayName, 'Ompha');
    });
  });
}
