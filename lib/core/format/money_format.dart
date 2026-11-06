/// Turns cents into text like "R 3 450.00".
/// (South African style grouping. This will move into the translation
/// system later so each language can format numbers its own way.)
String formatRand(int cents) {
  final negative = cents < 0;
  final abs = cents.abs();
  final rands = abs ~/ 100;
  final centsPart = (abs % 100).toString().padLeft(2, '0');
  final digits = rands.toString();

  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(' ');
    grouped.write(digits[i]);
  }

  return '${negative ? '-' : ''}R $grouped.$centsPart';
}

/// Turns what a user typed into cents, or null if it isn't a valid amount.
/// Accepts "12", "12.5", "12,50" and "1 200". Rejects negatives, letters,
/// and more than 2 decimal places.
int? parseRandToCents(String input) {
  final cleaned = input.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) return null;

  final parts = cleaned.split('.');
  final rands = int.parse(parts[0]);
  final cents = parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0;
  return rands * 100 + cents;
}