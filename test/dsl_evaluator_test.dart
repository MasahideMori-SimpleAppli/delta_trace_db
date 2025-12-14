import 'package:test/test.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

void main() {
  group('UtilDslEvaluator Parse Test', () {
    late Map<String, dynamic> base;
    late List<Map<String, dynamic>> source;

    setUp(() {
      base = {
        'a': 1,
        'b': {'c': 2, 'd': 3},
      };

      source = [
        {
          'x': 10,
          'y': {'z': 20},
        },
        {
          'p': {'q': 30},
        },
      ];
    });

    test('none / null returns null', () {
      expect(UtilDslEvaluator.parse('none', base, source), isNull);
      expect(UtilDslEvaluator.parse('null', base, source), isNull);
    });

    test('int literal', () {
      expect(UtilDslEvaluator.parse('int(123)', base, source), equals(123));
      expect(UtilDslEvaluator.parse('int(-5)', base, source), equals(-5));
    });

    test('float literal', () {
      expect(UtilDslEvaluator.parse('float(1.5)', base, source), equals(1.5));
      expect(
        UtilDslEvaluator.parse('float(-2.25)', base, source),
        equals(-2.25),
      );
    });

    test('bool literal', () {
      expect(UtilDslEvaluator.parse('bool(true)', base, source), isTrue);
      expect(UtilDslEvaluator.parse('bool(false)', base, source), isFalse);
    });

    test('invalid bool literal throws', () {
      expect(
        () => UtilDslEvaluator.parse('bool(TRUE)', base, source),
        throwsFormatException,
      );
    });

    test('string literal', () {
      expect(
        UtilDslEvaluator.parse('str(hello)', base, source),
        equals('hello'),
      );
    });

    test('base reference without keyPath', () {
      final result = UtilDslEvaluator.parse('base', base, source);
      expect(result, equals(base));
    });

    test('base reference with keyPath', () {
      expect(UtilDslEvaluator.parse('base.a', base, source), equals(1));
      expect(UtilDslEvaluator.parse('base.b.c', base, source), equals(2));
    });

    test('source reference without keyPath', () {
      final result = UtilDslEvaluator.parse('0', base, source);
      expect(result, equals(source[0]));
    });

    test('source reference with keyPath', () {
      expect(UtilDslEvaluator.parse('0.x', base, source), equals(10));
      expect(UtilDslEvaluator.parse('0.y.z', base, source), equals(20));
      expect(UtilDslEvaluator.parse('1.p.q', base, source), equals(30));
    });

    test('array wrap wraps evaluated value', () {
      expect(UtilDslEvaluator.parse('[int(1)]', base, source), equals([1]));
      expect(UtilDslEvaluator.parse('[base.a]', base, source), equals([1]));
      expect(UtilDslEvaluator.parse('[0.y.z]', base, source), equals([20]));
    });

    test('nested array wrap', () {
      expect(
        UtilDslEvaluator.parse('[[base.a]]', base, source),
        equals([
          [1],
        ]),
      );
    });

    test('popped removes specified paths from base', () {
      final result =
          UtilDslEvaluator.parse('popped.base[b.c]', base, source)
              as Map<String, dynamic>;

      expect(result.containsKey('a'), isTrue);
      expect(result['b'], isA<Map<String, dynamic>>());
      expect(result['b']['c'], isNull);
      expect(result['b']['d'], equals(3));

      // 元データは変更されていない
      expect(base['b']['c'], equals(2));
    });

    test('popped removes multiple paths', () {
      final result =
          UtilDslEvaluator.parse('popped.base[b.c,b.d]', base, source)
              as Map<String, dynamic>;

      expect(result['b'], equals({}));
    });

    test('popped ignores non-existent paths', () {
      final result =
          UtilDslEvaluator.parse('popped.base[x.y]', base, source)
              as Map<String, dynamic>;

      // 何も変わらない
      expect(result, equals(base));
    });

    test('invalid DSL throws FormatException', () {
      expect(
        () => UtilDslEvaluator.parse('', base, source),
        throwsFormatException,
      );

      expect(
        () => UtilDslEvaluator.parse('base.', base, source),
        throwsFormatException,
      );
    });
  });
}
