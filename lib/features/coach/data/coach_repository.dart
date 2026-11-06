import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:moreki/features/coach/domain/coach_models.dart';

/// Where the Coach gets its saved answers from.
/// A fake version is used in tests, so tests don't need real files.
abstract class CoachRepository {
  Future<CoachData> load();
}

/// Reads the saved answers from a JSON file bundled with the app.
class AssetCoachRepository implements CoachRepository {
  AssetCoachRepository({
    this.assetPath = 'assets/coach/coach_en.json',
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  /// One file per language, e.g. assets/coach/coach_fr.json.
  /// The file for a language must exist before you ask for it.
  factory AssetCoachRepository.forLanguage(
      String languageCode, {
        AssetBundle? bundle,
      }) =>
      AssetCoachRepository(
        assetPath: 'assets/coach/coach_$languageCode.json',
        bundle: bundle,
      );

  final String assetPath;
  final AssetBundle _bundle;

  @override
  Future<CoachData> load() async {
    final source = await _bundle.loadString(assetPath);
    return CoachData.fromJsonString(source);
  }
}