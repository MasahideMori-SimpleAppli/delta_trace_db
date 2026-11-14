import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

/// Tests for EnumValueType.decimal_ and EnumValueType.rational_.
DeltaTraceDatabase _createDb() {
  final db = DeltaTraceDatabase();
  db.executeQuery(
    RawQueryBuilder.add(
      target: "item",
      rawAddData: [
        {"id": "a", "v": "10.5"},
        {"id": "b", "v": "9.99999999999999999999"},
        {"id": "c", "v": "10.50"},
        {"id": "d", "v": 2.5}, // numbers are not converted.
        {"id": "e", "v": "abc"},
        {"id": "f", "v": "11"},
        {"id": "g"},
      ],
    ).build(),
  );
  return db;
}

Set<String> _ids(DeltaTraceDatabase db, QueryNode node) {
  final r = db.executeQuery(
    RawQueryBuilder.search(target: "item", queryNode: node).build(),
  );
  expect(r.isSuccess, true);
  return r.result.map((e) => e["id"] as String).toSet();
}

void main() {
  test('decimal_ comparison', () {
    final db = _createDb();
    final t = EnumValueType.decimal_;
    expect(_ids(db, FieldGreaterThan("v", "10", vType: t)), {"a", "c", "f"});
    expect(_ids(db, FieldEquals("v", "10.5", vType: t)), {"a", "c"});
    expect(_ids(db, FieldNotEquals("v", "10.5", vType: t)), {"b", "f"});
    expect(_ids(db, FieldLessThan("v", "10", vType: t)), {"b"});
    expect(_ids(db, FieldGreaterThanOrEqual("v", "11", vType: t)), {"f"});
    expect(_ids(db, FieldLessThanOrEqual("v", "10.5", vType: t)), {
      "a",
      "b",
      "c",
    });
    // Beyond double precision: both strings become 10.0 as double.
    const q = "9.999999999999999999991";
    expect(_ids(db, FieldEquals("v", q, vType: t)), <String>{});
    expect(_ids(db, FieldLessThan("v", q, vType: t)), {"b"});
    expect(_ids(db, FieldEquals("v", q, vType: EnumValueType.floatStrict_)), {
      "b",
    });
  });

  test('numbers are not converted', () {
    final db = DeltaTraceDatabase();
    db.executeQuery(
      RawQueryBuilder.add(
        target: "item",
        rawAddData: [
          {"id": "a", "v": 12},
          {"id": "b", "v": 12.0},
          {"id": "c", "v": true},
          {"id": "d", "v": "12"},
        ],
      ).build(),
    );
    for (final t in [EnumValueType.decimal_, EnumValueType.rational_]) {
      expect(_ids(db, FieldEquals("v", "12", vType: t)), {"d"});
      // A number as the query value is also a conversion failure.
      expect(_ids(db, FieldEquals("v", 12, vType: t)), <String>{});
    }
  });

  test('rational_ comparison', () {
    final db = _createDb();
    final t = EnumValueType.rational_;
    expect(_ids(db, FieldEquals("v", "21/2", vType: t)), {"a", "c"});
    expect(_ids(db, FieldGreaterThan("v", "32/3", vType: t)), {"f"});
  });

  test('vType is inferred from PortableDecimal / PortableRational', () {
    final db = _createDb();
    final n1 = FieldEquals("v", PortableDecimal.parse("10.5"));
    expect(n1.vType, EnumValueType.decimal_);
    expect(_ids(db, n1), {"a", "c"});
    final n2 = FieldGreaterThan("v", PortableRational.parse("32/3"));
    expect(n2.vType, EnumValueType.rational_);
    expect(_ids(db, n2), {"f"});
    // Serialized as a String and restored.
    final d = n1.toDict();
    expect(d["value"], "10.5");
    expect(d["vType"], "decimal_");
    final restored = QueryNode.fromDict(d);
    expect(_ids(db, restored), {"a", "c"});
  });

  test('decimal_ sort puts unconvertible values last', () {
    final db = _createDb();
    for (final reversed in [false, true]) {
      final r = db.executeQuery(
        RawQueryBuilder.search(
          target: "item",
          queryNode: FieldStartsWith("id", ""),
          sortObj: SingleSort(
            field: "v",
            reversed: reversed,
            vType: EnumValueType.decimal_,
          ),
        ).build(),
      );
      final ids = r.result.map((e) => e["id"] as String).toList();
      final converted = ["b", "a", "c", "f"];
      if (reversed) {
        expect(ids.sublist(0, 3).toSet(), {"d", "e", "g"});
        expect(ids[3], "f");
        expect(ids.sublist(4, 6).toSet(), {"a", "c"});
        expect(ids[6], "b");
      } else {
        expect(ids[0], converted[0]);
        expect(ids.sublist(1, 3).toSet(), {"a", "c"});
        expect(ids[3], "f");
        expect(ids.sublist(4).toSet(), {"d", "e", "g"});
      }
    }
  });

  test('rational_ multi sort', () {
    final db = _createDb();
    final r = db.executeQuery(
      RawQueryBuilder.search(
        target: "item",
        queryNode: FieldIn("id", ["a", "b", "c"]),
        sortObj: MultiSort([
          SingleSort(field: "v", vType: EnumValueType.rational_),
          SingleSort(field: "id", reversed: true),
        ]),
      ).build(),
    );
    expect(r.result.map((e) => e["id"]).toList(), ["b", "c", "a"]);
  });
}
