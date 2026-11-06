import 'package:flutter/widgets.dart';
import 'package:moreki/core/l10n/app_strings.dart';

/// Hands the current language to every screen below it.
///
/// Screens read their text with `AppLanguage.of(context).get('some.key')`.
/// When the code changes, every screen that asked for it rebuilds.
class AppLanguage extends InheritedWidget {
  AppLanguage({
    super.key,
    required this.code,
    required super.child,
  }) : strings = AppStrings(code);

  /// Language code such as 'en', 'fr' or 'af'.
  final String code;

  /// The text table for [code]. Unknown codes fall back to English.
  final AppStrings strings;

  /// The strings for the nearest [AppLanguage]. English if there is none
  /// (so a page built on its own in a test still works).
  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLanguage>();
    return scope?.strings ?? const AppStrings('en');
  }

  @override
  bool updateShouldNotify(AppLanguage oldWidget) => code != oldWidget.code;
}
