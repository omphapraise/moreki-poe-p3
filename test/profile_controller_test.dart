import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/profile/application/profile_controller.dart';
import 'package:moreki/features/profile/data/profile_store.dart';
import 'package:moreki/features/profile/domain/profile.dart';

class _MemoryStore implements ProfileStore {
  ProfileSettings stored = const ProfileSettings();

  @override
  Future<ProfileSettings> load() async => stored;

  @override
  Future<void> save(ProfileSettings settings) async {
    stored = settings;
  }
}

void main() {
  DateTime clock() => DateTime(2026, 10, 29, 10);

  test('starts empty, English, no payday', () {
    final c = ProfileController(clock: clock);
    expect(c.settings.displayName, '');
    expect(c.settings.languageCode, 'en');
    expect(c.payday, isNull);
  });

  test('saving details sets name and payday and tells listeners', () async {
    final c = ProfileController(clock: clock);
    var notified = 0;
    c.addListener(() => notified++);

    final ok = await c.saveDetails(displayName: '  Ompha ', paydayDay: 25);

    expect(ok, isTrue);
    expect(c.settings.displayName, 'Ompha');
    expect(c.payday?.daysAway, 27);
    expect(notified, greaterThan(0));
  });

  test('rejects a bad payday or a too-long name', () async {
    final c = ProfileController(clock: clock);
    expect(await c.saveDetails(displayName: 'A', paydayDay: 0), isFalse);
    expect(await c.saveDetails(displayName: 'A', paydayDay: 32), isFalse);
    expect(await c.saveDetails(displayName: 'x' * 41), isFalse);
    expect(c.settings.displayName, '');
  });

  test('payday can be cleared', () async {
    final c = ProfileController(clock: clock);
    await c.saveDetails(displayName: 'A', paydayDay: 25);
    await c.saveDetails(displayName: 'A');
    expect(c.settings.paydayDay, isNull);
    expect(c.payday, isNull);
  });

  test('only known languages are accepted and the name is kept', () async {
    final c = ProfileController(clock: clock);
    await c.saveDetails(displayName: 'Ompha', paydayDay: 25);
    expect(await c.setLanguage('zz'), isFalse);
    expect(c.settings.languageCode, 'en');
    expect(await c.setLanguage('fr'), isTrue);
    expect(c.settings.languageCode, 'fr');
    expect(await c.setLanguage('af'), isTrue);
    expect(c.settings.languageCode, 'af');
    expect(c.settings.displayName, 'Ompha');
    expect(c.settings.paydayDay, 25);
  });

  test('the cut languages (Tshivenda, siSwati) are rejected', () async {
    final c = ProfileController(clock: clock);
    expect(await c.setLanguage('ve'), isFalse);
    expect(await c.setLanguage('ss'), isFalse);
    expect(c.settings.languageCode, 'en');
  });

  test('everything is saved and loads back in a new controller', () async {
    final store = _MemoryStore();
    final first = ProfileController(store: store, clock: clock);
    await first.saveDetails(displayName: 'Ompha', paydayDay: 28);
    await first.setLanguage('af');

    final second = ProfileController(store: store, clock: clock);
    expect(second.loaded, isFalse);
    await second.load();

    expect(second.loaded, isTrue);
    expect(second.settings.displayName, 'Ompha');
    expect(second.settings.paydayDay, 28);
    expect(second.settings.languageCode, 'af');
  });
}
