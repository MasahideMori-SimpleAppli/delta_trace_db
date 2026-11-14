import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

/// Tests for the aggregate query. The Python version has the same cases.
DeltaTraceDatabase _createDb() {
  final db = DeltaTraceDatabase();
  db.executeQuery(
    RawQueryBuilder.add(
      target: "order",
      rawAddData: [
        {"id": 1, "status": "paid", "price": "10.50", "qty": 2, "memo": "a"},
        {"id": 2, "status": "paid", "price": "3.3", "qty": 1.5, "memo": null},
        {"id": 3, "status": "paid", "price": "30", "qty": "4"},
        {"id": 4, "status": "cancel", "price": "100", "qty": 10, "memo": "b"},
        {"id": 5, "status": "paid", "price": null, "qty": null, "memo": true},
      ],
    ).build(),
  );
  return db;
}

QueryResult _run(
  DeltaTraceDatabase db,
  List<Aggregation> aggregations, {
  QueryNode? node,
  String target = "order",
}) {
  return db.executeQuery(
    RawQueryBuilder.aggregate(
      target: target,
      aggregations: aggregations,
      queryNode: node,
    ).build(),
  );
}

void main() {
  final paid = FieldEquals("status", "paid");

  test('decimal_ aggregation', () {
    final db = _createDb();
    const t = EnumValueType.decimal_;
    final r = _run(db, [
      Aggregation(EnumAggregateType.count_),
      Aggregation(EnumAggregateType.count_, field: "price"),
      Aggregation(EnumAggregateType.sum_, field: "price", vType: t),
      Aggregation(EnumAggregateType.min_, field: "price", vType: t),
      Aggregation(EnumAggregateType.max_, field: "price", vType: t),
      Aggregation(
        EnumAggregateType.mean_,
        field: "price",
        vType: t,
        scale: 2,
        rounding: EnumRoundingMode.halfEven,
        alias: "avg",
      ),
    ], node: paid);
    expect(r.isSuccess, true);
    expect(r.hitCount, 4);
    expect(r.result, [
      {
        "count_": 4,
        "count_price": 3,
        "sum_price": "43.80",
        "min_price": "3.3",
        "max_price": "30",
        "avg": "14.60",
      },
    ]);
  });

  test('rational_ aggregation', () {
    final db = _createDb();
    const t = EnumValueType.rational_;
    final r = _run(db, [
      Aggregation(EnumAggregateType.sum_, field: "price", vType: t),
      Aggregation(EnumAggregateType.mean_, field: "price", vType: t),
      Aggregation(EnumAggregateType.min_, field: "price", vType: t),
    ], node: paid);
    expect(r.result.first, {
      "sum_price": "219/5",
      "mean_price": "73/5",
      "min_price": "33/10",
    });
  });

  test('floatStrict_ aggregation', () {
    final db = _createDb();
    final r = _run(db, [
      Aggregation(EnumAggregateType.sum_, field: "qty"),
      Aggregation(EnumAggregateType.mean_, field: "qty"),
      Aggregation(EnumAggregateType.min_, field: "qty"),
      Aggregation(EnumAggregateType.max_, field: "qty"),
      Aggregation(EnumAggregateType.count_, field: "memo"),
    ]);
    expect(r.result.first, {
      "sum_qty": 17.5,
      "mean_qty": 4.375,
      "min_qty": 1.5,
      "max_qty": 10.0,
      "count_memo": 3,
    });
  });

  test('floatStrict_ uses simple left-to-right addition', () {
    final db = DeltaTraceDatabase();
    db.executeQuery(
      RawQueryBuilder.add(
        target: "v",
        rawAddData: List.generate(10, (_) => {"x": 0.1}),
      ).build(),
    );
    final r = _run(db, [
      Aggregation(EnumAggregateType.sum_, field: "x"),
    ], target: "v");
    // Python's built-in sum() (3.12+) would return 1.0 here.
    expect(r.result.first["sum_x"], 0.9999999999999999);
  });

  test('floatStrict_ accepts only plain number strings', () {
    for (final ok in ["1e3", ".5", "1.", "-2.5E-1", "+7"]) {
      final db = DeltaTraceDatabase();
      db.executeQuery(
        RawQueryBuilder.add(
          target: "v",
          rawAddData: [
            {"x": ok},
          ],
        ).build(),
      );
      final r = _run(db, [
        Aggregation(EnumAggregateType.sum_, field: "x"),
      ], target: "v");
      expect(r.isSuccess, true, reason: ok);
      expect(r.result.first["sum_x"], double.parse(ok), reason: ok);
    }
    for (final ng in ["1_000", "inf", "NaN", " 1", "0x10", "1e999", "", true]) {
      final db = DeltaTraceDatabase();
      db.executeQuery(
        RawQueryBuilder.add(
          target: "v",
          rawAddData: [
            {"x": ng},
          ],
        ).build(),
      );
      final r = _run(db, [
        Aggregation(EnumAggregateType.sum_, field: "x"),
      ], target: "v");
      expect(r.isSuccess, false, reason: "$ng");
    }
  });

  test('empty target', () {
    final db = _createDb();
    final r = _run(db, [
      Aggregation(EnumAggregateType.count_),
      Aggregation(EnumAggregateType.sum_, field: "qty"),
      Aggregation(
        EnumAggregateType.sum_,
        field: "price",
        vType: EnumValueType.decimal_,
      ),
      Aggregation(EnumAggregateType.min_, field: "qty"),
      Aggregation(EnumAggregateType.mean_, field: "qty"),
    ], node: FieldEquals("status", "none"));
    expect(r.isSuccess, true);
    expect(r.hitCount, 0);
    expect(r.result.first, {
      "count_": 0,
      "sum_qty": 0.0,
      "sum_price": "0",
      "min_qty": null,
      "mean_qty": null,
    });
  });

  test('errors', () {
    final db = _createDb();
    final errors = [
      // Numbers are not converted with decimal_.
      Aggregation(
        EnumAggregateType.sum_,
        field: "qty",
        vType: EnumValueType.decimal_,
      ),
      // mean_ with decimal_ requires scale and rounding.
      Aggregation(
        EnumAggregateType.mean_,
        field: "price",
        vType: EnumValueType.decimal_,
      ),
      // Unsupported vType.
      Aggregation(
        EnumAggregateType.sum_,
        field: "qty",
        vType: EnumValueType.int_,
      ),
      // Field is required.
      Aggregation(EnumAggregateType.sum_),
    ];
    for (final a in errors) {
      final r = _run(db, [a]);
      expect(r.isSuccess, false, reason: a.toDict().toString());
      expect(r.errorMessage, isNotNull);
    }
    // Duplicate key.
    final r = _run(db, [
      Aggregation(EnumAggregateType.count_),
      Aggregation(EnumAggregateType.sum_, field: "qty", alias: "count_"),
    ]);
    expect(r.isSuccess, false);
  });

  test('serialization round trip', () {
    final db = _createDb();
    final q = RawQueryBuilder.aggregate(
      target: "order",
      queryNode: paid,
      aggregations: [
        Aggregation(
          EnumAggregateType.mean_,
          field: "price",
          vType: EnumValueType.decimal_,
          scale: 3,
          rounding: EnumRoundingMode.down,
          alias: "avg",
        ),
      ],
    ).build();
    final q2 = QueryBuilder.aggregate(
      target: "order",
      queryNode: paid,
      aggregations: q.aggregations!,
    ).build();
    expect(q2.toDict(), q.toDict());
    final restored = Query.fromDict(q.toDict());
    expect(restored.toDict(), q.toDict());
    expect(db.executeQuery(restored).result.first, {"avg": "14.600"});
  });

  test('permission', () {
    final db = _createDb();
    final q = RawQueryBuilder.aggregate(
      target: "order",
      aggregations: [Aggregation(EnumAggregateType.count_)],
    ).build();
    // search permission does not allow aggregate.
    var r = db.executeQuery(
      q,
      collectionPermissions: {
        "order": Permission([EnumQueryType.search]),
      },
    );
    expect(r.isSuccess, false);
    r = db.executeQuery(
      q,
      collectionPermissions: {
        "order": Permission([EnumQueryType.aggregate]),
      },
    );
    expect(r.isSuccess, true);
    expect(r.result.first, {"count_": 5});
  });
}
