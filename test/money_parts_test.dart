import 'package:flutter_test/flutter_test.dart';
import 'package:moreki/core/format/money_parts.dart';

void main() {
  test('splits a normal Rand amount into big part and small cents', () {
    final p = splitRandForDisplay('R 58 000.00');
    expect(p.whole, 'R 58 000');
    expect(p.cents, '.00');
  });

  test('keeps non-zero cents', () {
    final p = splitRandForDisplay('R 0.50');
    expect(p.whole, 'R 0');
    expect(p.cents, '.50');
  });

  test('works with a minus sign', () {
    final p = splitRandForDisplay('-R 12.50');
    expect(p.whole, '-R 12');
    expect(p.cents, '.50');
  });

  test('leaves text without cents alone', () {
    final p = splitRandForDisplay('R 100');
    expect(p.whole, 'R 100');
    expect(p.cents, isNull);
  });

  test('does not split when there are not exactly two digits after the dot',
          () {
        expect(splitRandForDisplay('R 1.5').cents, isNull);
        expect(splitRandForDisplay('R 1.555').cents, isNull);
      });
}