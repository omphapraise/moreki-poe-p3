/// A language the person can pick.
class AppLanguage {
  const AppLanguage(this.code, this.label);

  final String code;
  final String label;
}

/// What the person has told us about themselves.
class ProfileSettings {
  const ProfileSettings({
    this.displayName = '',
    this.languageCode = 'en',
    this.paydayDay,
  });

  /// Optional first name or nickname.
  final String displayName;

  /// One of [ProfileSettings.languages] codes.
  final String languageCode;

  /// Day of the month the person gets paid (1 to 31). Null = not set.
  final int? paydayDay;

  static const int maxNameLength = 40;

  static const List<AppLanguage> languages = [
    AppLanguage('en', 'English'),
    AppLanguage('fr', 'Fran\u00E7ais'),
    AppLanguage('af', 'Afrikaans'),
  ];

  static bool isSupportedLanguage(String code) =>
      languages.any((l) => l.code == code);
}

/// When the next payday is.
class PaydayInfo {
  const PaydayInfo({required this.date, required this.daysAway});

  final DateTime date;

  /// 0 = today.
  final int daysAway;
}

/// Payday maths. Pure Dart, no Flutter, fully tested.
class PaydayCalculator {
  const PaydayCalculator._();

  /// The payday in the given month. A payday later than the month's last day
  /// (say the 31st in February) falls on the last day of that month.
  static DateTime _paydayIn(int year, int month, int day) {
    final first = DateTime(year, month, 1);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(first.year, first.month, day > lastDay ? lastDay : day);
  }

  /// The next payday on or after [today]. [paydayDay] must be 1 to 31.
  static PaydayInfo next(DateTime today, int paydayDay) {
    final t = DateTime(today.year, today.month, today.day);
    var payday = _paydayIn(t.year, t.month, paydayDay);
    if (payday.isBefore(t)) {
      payday = _paydayIn(t.year, t.month + 1, paydayDay);
    }
    final days = DateTime.utc(payday.year, payday.month, payday.day)
        .difference(DateTime.utc(t.year, t.month, t.day))
        .inDays;
    return PaydayInfo(date: payday, daysAway: days);
  }
}
