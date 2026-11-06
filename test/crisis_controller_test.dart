import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/crisis/application/crisis_controller.dart';
import 'package:moreki/features/crisis/data/crisis_store.dart';
import 'package:moreki/features/crisis/domain/crisis.dart';

class _MemoryStore implements CrisisStore {
  _MemoryStore([CrisisData? start]) : data = start ?? const CrisisData();

  CrisisData data;
  int saves = 0;

  @override
  Future<CrisisData> load() async => data;

  @override
  Future<void> save(CrisisData d) async {
    data = d;
    saves++;
  }
}

class _BrokenStore implements CrisisStore {
  @override
  Future<CrisisData> load() async => throw Exception('load failed');

  @override
  Future<void> save(CrisisData d) async => throw Exception('save failed');
}

void main() {
  group('CrisisController', () {
    test('starts empty', () {
      final c = CrisisController();
      expect(c.summary.hasData, isFalse);
      expect(c.plan.toJson(), const CrisisPlan().toJson());
    });

    test('updatePlan changes the summary and tells listeners', () async {
      final c = CrisisController();
      var notified = 0;
      c.addListener(() => notified++);
      final ok = await c.updatePlan(
        const CrisisPlan(incomeCents: 1000000, rentCents: 400000),
      );
      expect(ok, isTrue);
      expect(notified, 1);
      expect(c.summary.leftCents, 600000);
    });

    test('updatePlan rejects a negative amount and changes nothing', () async {
      final c = CrisisController();
      final ok = await c.updatePlan(const CrisisPlan(rentCents: -1));
      expect(ok, isFalse);
      expect(c.summary.hasData, isFalse);
    });

    test('saves to the store when one is given', () async {
      final store = _MemoryStore();
      final c = CrisisController(store: store);
      await c.updatePlan(const CrisisPlan(incomeCents: 500));
      expect(store.saves, 1);
      expect(store.data.plan.incomeCents, 500);
    });

    test('load brings back saved numbers', () async {
      final store = _MemoryStore(
        const CrisisData(plan: CrisisPlan(incomeCents: 900, foodCents: 100)),
      );
      final c = CrisisController(store: store);
      await c.load();
      expect(c.plan.incomeCents, 900);
      expect(c.plan.foodCents, 100);
    });

    test('clearAll empties the numbers and saves the empty state', () async {
      final store = _MemoryStore();
      final c = CrisisController(store: store);
      await c.updatePlan(const CrisisPlan(incomeCents: 500));
      await c.clearAll();
      expect(c.summary.hasData, isFalse);
      expect(store.data.plan.incomeCents, 0);
    });

    test('a broken store never crashes the controller', () async {
      final c = CrisisController(store: _BrokenStore());
      await c.load();
      final ok = await c.updatePlan(const CrisisPlan(incomeCents: 100));
      await c.clearAll();
      expect(ok, isTrue);
    });
  });
}
