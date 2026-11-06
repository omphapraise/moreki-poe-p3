import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/format/money_format.dart';

void main() {
  group('formatRand', () {
    test('formats cents as Rand with grouping', () {
      expect(formatRand(345000), 'R 3 450.00');
      expect(formatRand(5), 'R 0.05');
      expect(formatRand(100000000), 'R 1 000 000.00');
      expect(formatRand(0), 'R 0.00');
    });

    test('formats negative amounts', () {
      expect(formatRand(-1250), '-R 12.50');
    });
  });

  group('parseRandToCents', () {
    test('accepts valid amounts', () {
      expect(parseRandToCents('12'), 1200);
      expect(parseRandToCents('12.5'), 1250);
      expect(parseRandToCents('12,50'), 1250);
      expect(parseRandToCents('1 200'), 120000);
      expect(parseRandToCents('  250  '), 25000);
    });

    test('rejects invalid input', () {
      expect(parseRandToCents(''), isNull);
      expect(parseRandToCents('abc'), isNull);
      expect(parseRandToCents('-5'), isNull);
      expect(parseRandToCents('12.345'), isNull);
      expect(parseRandToCents('1.2.3'), isNull);
    });
  });
}