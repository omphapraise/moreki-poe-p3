import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/side_hustle/data/side_hustle_store.dart';
import 'package:moreki/features/side_hustle/domain/side_hustle.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'moreki_side_hustle_v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsSideHustleStore', () {
    test('loads empty data when nothing has been saved', () async {
      SharedPreferences.setMockInitialValues({});
      final data = await SharedPrefsSideHustleStore().load();
      expect(data.entries, isEmpty);
    });

    test('saves and loads entries', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPrefsSideHustleStore();

      await store.save(
        SideHustleData(
          entries: [
            HustleEntry(
              id: 'a',
              type: HustleEntryType.income,
              amountCents: 45000,
              date: DateTime(2026, 11, 1, 9, 30),
              note: 'braai plates',
            ),
            HustleEntry(
              id: 'b',
              type: HustleEntryType.cost,
              amountCents: 12050,
              date: DateTime(2026, 11, 2, 18, 5),
            ),
          ],
        ),
      );

      // A brand new store object proves the data really came from storage.
      final loaded = await SharedPrefsSideHustleStore().load();

      expect(loaded.entries.length, 2);
      expect(loaded.entries[0].id, 'a');
      expect(loaded.entries[0].type, HustleEntryType.income);
      expect(loaded.entries[0].amountCents, 45000);
      expect(loaded.entries[0].note, 'braai plates');
      expect(loaded.entries[1].type, HustleEntryType.cost);
      expect(loaded.entries[1].amountCents, 12050);
      expect(loaded.entries[1].date, DateTime(2026, 11, 2, 18, 5));
    });

    test('loads empty data instead of crashing when data is damaged',
        () async {
      SharedPreferences.setMockInitialValues({_key: 'this is not json {{'});
      final data = await SharedPrefsSideHustleStore().load();
      expect(data.entries, isEmpty);
    });

    test('loads empty data when saved JSON is missing fields', () async {
      SharedPreferences.setMockInitialValues({_key: '{"other": 1}'});
      final data = await SharedPrefsSideHustleStore().load();
      expect(data.entries, isEmpty);
    });

    test('loads empty data when an entry has a bad amount', () async {
      SharedPreferences.setMockInitialValues({
        _key: '{"entries":[{"id":"a","type":"income","amountCents":-5,'
            '"date":"2026-11-01T00:00:00.000"}]}',
      });
      final data = await SharedPrefsSideHustleStore().load();
      expect(data.entries, isEmpty);
    });
  });
}
