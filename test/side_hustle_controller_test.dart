import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/side_hustle/application/side_hustle_controller.dart';
import 'package:moreki/features/side_hustle/data/side_hustle_store.dart';
import 'package:moreki/features/side_hustle/domain/side_hustle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStore implements SideHustleStore {
  SideHustleData saved = const SideHustleData();
  int saves = 0;

  @override
  Future<SideHustleData> load() async => saved;

  @override
  Future<void> save(SideHustleData data) async {
    saved = data;
    saves++;
  }
}

class _BrokenStore implements SideHustleStore {
  @override
  Future<SideHustleData> load() async => throw Exception('boom');

  @override
  Future<void> save(SideHustleData data) async => throw Exception('boom');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 11, 4, 12);

  SideHustleController make([SideHustleStore? store]) =>
      SideHustleController(store: store, clock: () => today);

  group('SideHustleController', () {
    test('starts empty', () {
      final c = make();
      expect(c.entries, isEmpty);
      expect(c.allTime.keepCents, 0);
      expect(c.thisMonth.entryCount, 0);
    });

    test('adds income and costs and works out what you keep', () async {
      final c = make();
      expect(
        await c.addEntry(
          type: HustleEntryType.income,
          amountCents: 80000,
          note: '  cakes  ',
        ),
        isTrue,
      );
      expect(
        await c.addEntry(type: HustleEntryType.cost, amountCents: 20000),
        isTrue,
      );
      expect(c.allTime.incomeCents, 80000);
      expect(c.allTime.costCents, 20000);
      expect(c.allTime.keepCents, 60000);
      expect(c.allTime.keepPercent, 75);
      expect(c.entries.length, 2);
      expect(c.entries.last.note, 'cakes');
    });

    test('rejects zero or negative amounts and changes nothing', () async {
      final c = make();
      expect(
        await c.addEntry(type: HustleEntryType.income, amountCents: 0),
        isFalse,
      );
      expect(
        await c.addEntry(type: HustleEntryType.cost, amountCents: -100),
        isFalse,
      );
      expect(c.entries, isEmpty);
    });

    test('lists newest date first, and this month ignores other months',
        () async {
      final c = make();
      await c.addEntry(
        type: HustleEntryType.income,
        amountCents: 1000,
        date: DateTime(2026, 10, 30),
      );
      await c.addEntry(
        type: HustleEntryType.income,
        amountCents: 2000,
        date: DateTime(2026, 11, 3),
      );
      await c.addEntry(
        type: HustleEntryType.cost,
        amountCents: 500,
        date: DateTime(2026, 11, 1),
      );
      expect(c.entries.map((e) => e.amountCents).toList(), [2000, 500, 1000]);
      expect(c.thisMonth.incomeCents, 2000);
      expect(c.thisMonth.costCents, 500);
      expect(c.thisMonth.entryCount, 2);
      expect(c.allTime.incomeCents, 3000);
    });

    test('deletes an entry, and can put it back for Undo', () async {
      final c = make();
      await c.addEntry(type: HustleEntryType.income, amountCents: 5000);
      final entry = c.entries.single;

      expect(await c.deleteEntry('nope'), isFalse);
      expect(await c.deleteEntry(entry.id), isTrue);
      expect(c.entries, isEmpty);

      await c.restoreEntry(entry);
      await c.restoreEntry(entry);
      expect(c.entries.length, 1);
      expect(c.allTime.incomeCents, 5000);
    });

    test('clearAll wipes everything', () async {
      final c = make();
      await c.addEntry(type: HustleEntryType.income, amountCents: 5000);
      await c.clearAll();
      expect(c.entries, isEmpty);
      expect(c.allTime.keepCents, 0);
    });

    test('saves after every change and loads it back', () async {
      final store = _FakeStore();
      final c = make(store);
      await c.addEntry(type: HustleEntryType.income, amountCents: 7000);
      await c.addEntry(type: HustleEntryType.cost, amountCents: 1000);
      expect(store.saves, 2);
      expect(store.saved.entries.length, 2);

      final fresh = make(store);
      await fresh.load();
      expect(fresh.allTime.keepCents, 6000);

      await fresh.clearAll();
      expect(store.saved.entries, isEmpty);
    });

    test('works with real saved prefs across controllers', () async {
      SharedPreferences.setMockInitialValues({});
      final first = make(SharedPrefsSideHustleStore());
      await first.addEntry(type: HustleEntryType.income, amountCents: 12345);

      final second = make(SharedPrefsSideHustleStore());
      await second.load();
      expect(second.allTime.incomeCents, 12345);
    });

    test('a broken store never crashes the controller', () async {
      final c = make(_BrokenStore());
      await c.load();
      expect(
        await c.addEntry(type: HustleEntryType.income, amountCents: 100),
        isTrue,
      );
      expect(c.entries.length, 1);
      await c.clearAll();
      expect(c.entries, isEmpty);
    });
  });
}
