import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

/// Conversion rules of EnumValueType that must match the Python version
/// (tests/test_value_type_consistency.py has the same cases).
List<int> _sorted(List<Object?> values, SingleSort sort) {
  final db = DeltaTraceDatabase();
  db.executeQuery(
    RawQueryBuilder.add(
      target: "x",
      rawAddData: [
        for (var i = 0; i < values.length; i++) {"i": i, "v": values[i]},
      ],
    ).build(),
  );
  final r = db.executeQuery(
    RawQueryBuilder.getAll(target: "x", sortObj: sort).build(),
  );
  expect(r.isSuccess, true);
  return r.result.map((e) => e["i"] as int).toList();
}

bool _eq(Object? fieldValue, Object? value, EnumValueType t) =>
    FieldEquals("v", value, vType: t).evaluate({"v": fieldValue});

void main() {
  test('sort treats values that cannot be converted as null', () {
    for (final t in [
      EnumValueType.int_,
      EnumValueType.floatStrict_,
      EnumValueType.floatEpsilon12_,
    ]) {
      for (final bad in [
        "abc",
        true,
        "NaN",
        {"a": 1},
      ]) {
        expect(
          _sorted(["2", bad, "1"], SingleSort(field: "v", vType: t)),
          [2, 0, 1],
          reason: "${t.name} $bad",
        );
        expect(
          _sorted([
            "2",
            bad,
            "1",
          ], SingleSort(field: "v", vType: t, reversed: true)),
          [1, 0, 2],
          reason: "${t.name} $bad reversed",
        );
      }
    }
    expect(
      _sorted([
        "yes",
        "maybe",
        false,
      ], SingleSort(field: "v", vType: EnumValueType.boolean_)),
      [2, 0, 1],
    );
    expect(
      _sorted([
        "2025-01-02T00:00:00Z",
        "abc",
        "2025-01-01T00:00:00Z",
      ], SingleSort(field: "v", vType: EnumValueType.datetime_)),
      [2, 0, 1],
    );
  });

  test('numeric strings are parsed like Dart int.parse / double.parse', () {
    expect(_eq("0x10", "16", EnumValueType.int_), true);
    expect(_eq(" 2 ", "2", EnumValueType.int_), true);
    expect(_eq("Infinity", "Infinity", EnumValueType.floatStrict_), true);
    for (final s in ["1_000", "１２", "99999999999999999999"]) {
      expect(_eq(s, s, EnumValueType.int_), false, reason: s);
    }
    for (final s in ["1_000", "１２", "inf", "nan"]) {
      expect(_eq(s, s, EnumValueType.floatStrict_), false, reason: s);
    }
    expect(_eq(1.5, 1.5, EnumValueType.int_), false);
    expect(_eq(true, true, EnumValueType.floatStrict_), false);
  });

  test('boolean_ accepts only true / false', () {
    expect(_eq("True", true, EnumValueType.boolean_), true);
    expect(_eq("yes", "yes", EnumValueType.boolean_), false);
  });

  test('invalid date-times are conversion failures', () {
    final v = DateTime.utc(2025);
    for (final s in [
      "2025-13-01T00:00:00Z",
      "2025-02-30T00:00:00Z",
      "2025-01-01T24:00:00Z",
      "2025-01-01T00:00:00z",
      "2025-W01-1",
    ]) {
      expect(
        FieldGreaterThan(
          "v",
          v,
          vType: EnumValueType.datetime_,
        ).evaluate({"v": s}),
        false,
        reason: s,
      );
      expect(
        FieldNotEquals(
          "v",
          v,
          vType: EnumValueType.datetime_,
        ).evaluate({"v": s}),
        false,
        reason: s,
      );
    }
    expect(_eq("2025-01-01T09:00:00+09:00", v, EnumValueType.datetime_), true);
  });

  test('mixing naive and aware date-times is a conversion failure', () {
    final aware = DateTime.utc(2025);
    const naive = "2025-01-01T00:00:00";
    expect(FieldEquals("v", aware).evaluate({"v": naive}), false);
    expect(FieldNotEquals("v", aware).evaluate({"v": naive}), false);
    expect(FieldGreaterThanOrEqual("v", aware).evaluate({"v": naive}), false);
    expect(FieldLessThanOrEqual("v", aware).evaluate({"v": naive}), false);
    // Naive values are sorted after aware values (treated as null).
    final data = [
      "2025-01-03T00:00:00Z",
      "2025-01-01T00:00:00",
      "2025-01-02T00:00:00Z",
      "2024-01-01T00:00:00",
      null,
    ];
    final s = SingleSort(field: "v", vType: EnumValueType.datetime_);
    expect(_sorted(data, s), [2, 0, 3, 1, 4]);
    final r = SingleSort(
      field: "v",
      vType: EnumValueType.datetime_,
      reversed: true,
    );
    expect(_sorted(data, r), [4, 1, 3, 0, 2]);
  });

  test('naiveUtcOffsetMinutes resolves naive date-times', () {
    // "2025-01-01T09:00:00" at UTC+9 is 2025-01-01T00:00:00Z.
    final node = FieldEquals(
      "v",
      DateTime.utc(2025),
      vType: EnumValueType.datetime_,
      naiveUtcOffsetMinutes: 540,
    );
    expect(node.evaluate({"v": "2025-01-01T09:00:00"}), true);
    expect(node.evaluate({"v": "2025-01-01T00:00:00Z"}), true);
    expect(node.evaluate({"v": "2025-01-01T00:00:00"}), false);
    // A naive compare value is also converted.
    final local = FieldGreaterThan(
      "v",
      DateTime(2025, 1, 1, 9),
      vType: EnumValueType.datetime_,
      naiveUtcOffsetMinutes: 540,
    );
    expect(local.evaluate({"v": "2025-01-01T00:00:01Z"}), true);
    // Serialization keeps the offset.
    final d = node.toDict();
    expect(d["naiveUtcOffsetMinutes"], 540);
    expect(QueryNode.fromDict(d).evaluate({"v": "2025-01-01T09:00:00"}), true);
    // Sorting mixed values with an offset.
    final sort = SingleSort(
      field: "v",
      vType: EnumValueType.datetime_,
      naiveUtcOffsetMinutes: -300,
    );
    // 2025-01-01T00:00:00 at UTC-5 is 05:00Z.
    expect(
      _sorted([
        "2025-01-01T06:00:00Z",
        "2025-01-01T00:00:00",
        "2025-01-01T04:00:00Z",
      ], sort),
      [2, 1, 0],
    );
    expect(SingleSort.fromDict(sort.toDict()).naiveUtcOffsetMinutes, -300);
    expect(
      () => FieldEquals("v", DateTime.utc(2025), naiveUtcOffsetMinutes: 1440),
      throwsArgumentError,
    );
    expect(
      () => SingleSort(field: "v", naiveUtcOffsetMinutes: -1440),
      throwsArgumentError,
    );
  });
}
