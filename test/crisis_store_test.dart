import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/crisis/data/crisis_store.dart';
import 'package:moreki/features/crisis/domain/crisis.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsCrisisStore', () {
    test('loads an empty plan when nothing is saved', () async {
      final data = await SharedPrefsCrisisStore().load();
      expect(data.plan.toJson(), const CrisisPlan().toJson());
    });

    test('saves and loads the same numbers', () async {
      final store = SharedPrefsCrisisStore();
      const plan = CrisisPlan(
        incomeCents: 1500000,
        rentCents: 600000,
        foodCents: 250000,
        transportCents: 120000,
        debtCents: 300000,
        otherCents: 45000,
      );
      await store.save(const CrisisData(plan: plan));
      final back = await SharedPrefsCrisisStore().load();
      expect(back.plan.toJson(), plan.toJson());
    });

    test('loads an empty plan instead of crashing when data is damaged',
        () async {
      SharedPreferences.setMockInitialValues({
        'moreki_crisis_v1': 'this is not json',
      });
      final data = await SharedPrefsCrisisStore().load();
      expect(data.plan.toJson(), const CrisisPlan().toJson());
    });

    test('loads an empty plan when saved JSON is missing fields', () async {
      SharedPreferences.setMockInitialValues({
        'moreki_crisis_v1': '{"plan":{"incomeCents":100}}',
      });
      final data = await SharedPrefsCrisisStore().load();
      expect(data.plan.toJson(), const CrisisPlan().toJson());
    });

    test('loads an empty plan when a saved amount is negative', () async {
      SharedPreferences.setMockInitialValues({
        'moreki_crisis_v1':
            '{"plan":{"incomeCents":100,"rentCents":-5,"foodCents":0,'
                '"transportCents":0,"debtCents":0,"otherCents":0}}',
      });
      final data = await SharedPrefsCrisisStore().load();
      expect(data.plan.toJson(), const CrisisPlan().toJson());
    });
  });
}
