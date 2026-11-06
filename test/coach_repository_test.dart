import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/features/coach/data/coach_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the real coach_en.json from the app assets', () async {
    final data = await AssetCoachRepository().load();
    expect(data.language, 'en');
    expect(data.entries, isNotEmpty);
    expect(data.topics, isNotEmpty);
    expect(data.disclaimer, isNotEmpty);
  });

  test('a missing language file fails instead of returning nothing', () async {
    final repo = AssetCoachRepository.forLanguage('zz');
    await expectLater(repo.load(), throwsA(anything));
  });
}