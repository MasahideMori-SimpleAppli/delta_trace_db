import 'dart:convert';
import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  group('Comparison Nodes', () {
    test('FieldEquals evaluates true/false correctly', () {
      final node = FieldEquals('name', 'Alice');
      expect(node.evaluate({'name': 'Alice'}), isTrue);
      expect(node.evaluate({'name': 'Bob'}), isFalse);
    });

    test('FieldNotEquals evaluates correctly', () {
      final node = FieldNotEquals('age', 30);
      expect(node.evaluate({'age': 25}), isTrue);
      expect(node.evaluate({'age': 30}), isFalse);
    });

    test('FieldGreaterThan works', () {
      final node = FieldGreaterThan('score', 80);
      expect(node.evaluate({'score': 90}), isTrue);
      expect(node.evaluate({'score': 70}), isFalse);
    });

    test('FieldGreaterThanOrEqual works', () {
      final node = FieldGreaterThanOrEqual('score', 80);
      expect(node.evaluate({'score': 80}), isTrue);
      expect(node.evaluate({'score': 79}), isFalse);
    });

    test('FieldLessThan works', () {
      final node = FieldLessThan('score', 80);
      expect(node.evaluate({'score': 70}), isTrue);
      expect(node.evaluate({'score': 90}), isFalse);
    });

    test('FieldLessThanOrEqual works', () {
      final node = FieldLessThanOrEqual('score', 80);
      expect(node.evaluate({'score': 80}), isTrue);
      expect(node.evaluate({'score': 81}), isFalse);
    });
  });

  group('Logical Nodes', () {
    test('AndNode evaluates correctly', () {
      final node = AndNode([FieldEquals('x', 1), FieldEquals('y', 2)]);
      expect(node.evaluate({'x': 1, 'y': 2}), isTrue);
      expect(node.evaluate({'x': 1, 'y': 3}), isFalse);
    });

    test('OrNode evaluates correctly', () {
      final node = OrNode([FieldEquals('x', 1), FieldEquals('y', 2)]);
      expect(node.evaluate({'x': 0, 'y': 2}), isTrue);
      expect(node.evaluate({'x': 0, 'y': 0}), isFalse);
    });

    test('NotNode evaluates correctly', () {
      final node = NotNode(FieldEquals('z', 5));
      expect(node.evaluate({'z': 5}), isFalse);
      expect(node.evaluate({'z': 4}), isTrue);
    });
  });

  group('QueryNode', () {
    test('QueryNode evaluate works with logical/comparison mix', () {
      final query = AndNode([
        FieldEquals('type', 'user'),
        OrNode([FieldGreaterThan('age', 18), FieldEquals('role', 'admin')]),
      ]);

      expect(query.evaluate({'type': 'user', 'age': 20}), isTrue);
      expect(query.evaluate({'type': 'user', 'role': 'admin'}), isTrue);
      expect(query.evaluate({'type': 'user', 'age': 10}), isFalse);
      expect(query.evaluate({'type': 'bot', 'age': 30}), isFalse);
    });

    test('QueryNode handles nested logical structures', () {
      final query = NotNode(
        AndNode([FieldEquals('active', true), FieldLessThan('count', 5)]),
      );

      expect(query.evaluate({'active': true, 'count': 3}), isFalse);
      expect(query.evaluate({'active': false, 'count': 3}), isTrue);
      expect(query.evaluate({'active': true, 'count': 6}), isTrue);
    });

    group('Serialization', () {
      test('FieldEquals toDict/fromDict with JSON encode/decode', () {
        final node = FieldEquals('name', 'Alice');
        final jsonStr = jsonEncode(node.toDict());
        final restored = FieldEquals.fromDict(jsonDecode(jsonStr));
        expect(restored.evaluate({'name': 'Alice'}), isTrue);
        expect(restored.evaluate({'name': 'Bob'}), isFalse);
      });

      test('FieldGreaterThanOrEqual toDict/fromDict with JSON', () {
        final node = FieldGreaterThanOrEqual('score', 50);
        final jsonStr = jsonEncode(node.toDict());
        final restored = FieldGreaterThanOrEqual.fromDict(jsonDecode(jsonStr));
        expect(restored.evaluate({'score': 60}), isTrue);
        expect(restored.evaluate({'score': 40}), isFalse);
      });

      test('AndNode nested serialization', () {
        final node = AndNode([
          FieldEquals('type', 'user'),
          FieldGreaterThan('age', 18),
        ]);
        final jsonStr = jsonEncode(node.toDict());
        final restored = AndNode.fromDict(jsonDecode(jsonStr));
        expect(restored.evaluate({'type': 'user', 'age': 20}), isTrue);
        expect(restored.evaluate({'type': 'user', 'age': 10}), isFalse);
      });

      test('NotNode with nested OrNode serialization', () {
        final node = NotNode(
          OrNode([FieldEquals('x', 1), FieldEquals('y', 2)]),
        );
        final jsonStr = jsonEncode(node.toDict());
        final restored = NotNode.fromDict(jsonDecode(jsonStr));
        expect(restored.evaluate({'x': 0, 'y': 0}), isTrue);
        expect(restored.evaluate({'x': 1, 'y': 0}), isFalse);
      });

      test('Complex QueryNode serialization and deserialization', () {
        final original = AndNode([
          FieldEquals('role', 'admin'),
          OrNode([FieldLessThan('logins', 5), FieldGreaterThan('age', 40)]),
        ]);

        final jsonStr = jsonEncode(original.toDict());
        final decoded = jsonDecode(jsonStr);
        final restored = AndNode.fromDict(decoded);

        expect(restored.evaluate({'role': 'admin', 'logins': 2}), isTrue);
        expect(restored.evaluate({'role': 'admin', 'age': 45}), isTrue);
        expect(
          restored.evaluate({'role': 'admin', 'logins': 10, 'age': 30}),
          isFalse,
        );
        expect(restored.evaluate({'role': 'user', 'logins': 2}), isFalse);
      });
    });

    test('QueryNode.fromDict restores FieldEquals correctly', () {
      final original = FieldEquals('foo', 'bar');
      final jsonStr = jsonEncode(original.toDict());
      final restored = QueryNode.fromDict(jsonDecode(jsonStr));
      expect(restored is FieldEquals, isTrue);
      expect(restored.evaluate({'foo': 'bar'}), isTrue);
    });

    test('QueryNode.fromDict restores nested AndNode correctly', () {
      final original = AndNode([
        FieldEquals('a', 1),
        FieldGreaterThan('b', 10),
      ]);
      final jsonStr = jsonEncode(original.toDict());
      final restored = QueryNode.fromDict(jsonDecode(jsonStr));
      expect(restored is AndNode, isTrue);
      expect(restored.evaluate({'a': 1, 'b': 11}), isTrue);
      expect(restored.evaluate({'a': 1, 'b': 5}), isFalse);
    });

    test('QueryNode.fromDict restores complex NotNode -> OrNode', () {
      final original = NotNode(
        OrNode([FieldEquals('x', true), FieldLessThan('y', 5)]),
      );
      final jsonStr = jsonEncode(original.toDict());
      final restored = QueryNode.fromDict(jsonDecode(jsonStr));
      expect(restored is NotNode, isTrue);
      expect(
        restored.evaluate({'x': false, 'y': 10}),
        isTrue,
      ); // NOT(FALSE OR FALSE) = TRUE
      expect(
        restored.evaluate({'x': true, 'y': 10}),
        isFalse,
      ); // NOT(TRUE OR FALSE) = FALSE
    });
  });
}
