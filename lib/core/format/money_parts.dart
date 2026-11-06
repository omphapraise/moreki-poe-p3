/// Splits a formatted Rand string such as "R 58 000.00" into the big part
/// ("R 58 000") and the small part (".00") so hero numbers can show the
/// cents small. If the text has no two-digit cents, [cents] is null and
/// [whole] is the whole text.
({String whole, String? cents}) splitRandForDisplay(String formatted) {
  final dot = formatted.lastIndexOf('.');
  if (dot < 0 || formatted.length - dot != 3) {
    return (whole: formatted, cents: null);
  }
  final afterDot = formatted.substring(dot + 1);
  if (!RegExp(r'^\d{2}$').hasMatch(afterDot)) {
    return (whole: formatted, cents: null);
  }
  return (whole: formatted.substring(0, dot), cents: formatted.substring(dot));
}