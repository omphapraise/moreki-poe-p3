import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/l10n/app_strings.dart';

void main() {
  final en = AppStrings.table('en');
  final fr = AppStrings.table('fr');
  final af = AppStrings.table('af');

  group('AppStrings tables', () {
    test('French has every English key and no extras', () {
      expect(fr.keys.toSet(), en.keys.toSet());
    });

    test('Afrikaans has every English key and no extras', () {
      expect(af.keys.toSet(), en.keys.toSet());
    });

    test('no translation is empty', () {
      for (final table in [en, fr, af]) {
        for (final entry in table.entries) {
          expect(entry.value.trim(), isNotEmpty, reason: entry.key);
        }
      }
    });

    test('placeholders match English in every language', () {
      final placeholder = RegExp(r'\{[a-z]+\}');
      for (final key in en.keys) {
        final expected =
            placeholder.allMatches(en[key]!).map((m) => m.group(0)).toSet();
        expect(
          placeholder.allMatches(fr[key]!).map((m) => m.group(0)).toSet(),
          expected,
          reason: 'fr $key',
        );
        expect(
          placeholder.allMatches(af[key]!).map((m) => m.group(0)).toSet(),
          expected,
          reason: 'af $key',
        );
      }
    });
  });

  group('AppStrings lookups', () {
    test('returns the right language', () {
      expect(const AppStrings('en').get('profile.save'), 'Save');
      expect(const AppStrings('fr').get('profile.save'), 'Enregistrer');
      expect(const AppStrings('af').get('profile.save'), 'Stoor');
    });

    test('unknown language code falls back to English', () {
      expect(const AppStrings('ve').get('profile.save'), 'Save');
      expect(const AppStrings('').get('profile.save'), 'Save');
    });

    test('unknown key returns the key itself', () {
      expect(const AppStrings('fr').get('no.such.key'), 'no.such.key');
    });

    test('format swaps placeholders', () {
      expect(
        const AppStrings('en').format('profile.hi', {'name': 'Thabo'}),
        'Hi, Thabo',
      );
      expect(
        const AppStrings('af').format('profile.daysAway', {'n': '5'}),
        '5 dae',
      );
    });

    test('month names exist for 1 to 12 in every language', () {
      for (final code in AppStrings.codes) {
        final s = AppStrings(code);
        for (var m = 1; m <= 12; m++) {
          expect(s.month(m), isNot('month.$m'), reason: '$code $m');
        }
      }
    });

    test('French and Afrikaans differ from English on key labels', () {
      expect(const AppStrings('fr').get('profile.language'), 'Langue');
      expect(const AppStrings('af').get('profile.language'), 'Taal');
    });
  });
}
