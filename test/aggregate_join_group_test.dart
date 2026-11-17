import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

/// Creates a database with orders, order_items and products from CSV.
DeltaTraceDatabase _salesDb() {
  final db = DeltaTraceDatabase();
  for (final (name, csv) in [
    (
      'orders',
      'orderId,orderedAt\n'
          'o1,2026-09-30T15:30:00Z\n'
          'o2,2026-10-15T10:00:00\n'
          'o3,2026-11-02T09:00:00+09:00\n',
    ),
    (
      'order_items',
      'orderId,productId,quantity,unitPrice\n'
          'o1,P1,2,100.50\n'
          'o2,P1,1,100.50\n'
          'o2,P2,3,0\n'
          'o3,P2,1,0\n',
    ),
    ('products', 'id,name,unitsPerSet\nP1,apple,6\nP2,orange,10\n'),
  ]) {
    db.executeQuery(QueryBuilder.addCsv(target: name, csvText: csv).build());
  }
  return db;
}

/// Groups single date-time values by [key] and returns the labels.
List<dynamic> _labels(List<String?> values, AggregateGroupKey key) {
  final db = DeltaTraceDatabase();
  db.executeQuery(
    RawQueryBuilder.add(
      target: 't',
      rawAddData: [
        for (final v in values) {'at': v},
      ],
    ).build(),
  );
  final r = db.executeQuery(
    QueryBuilder.aggregate(
      target: 't',
      aggregations: [Aggregation(EnumAggregateType.count_)],
      groupBy: [key],
    ).build(),
  );
  expect(r.isSuccess, true, reason: r.errorMessage);
  return r.result.map((e) => e['at']).toList();
}

void main() {
  test('joins, monthly groups, products of fields and sorting', () {
    final db = _salesDb();
    final q = QueryBuilder.aggregate(
      target: 'order_items',
      joins: [
        AggregateJoin(
          collection: 'orders',
          localKey: 'orderId',
          foreignKey: 'orderId',
          alias: 'o',
        ),
        AggregateJoin(
          collection: 'products',
          localKey: 'productId',
          foreignKey: 'id',
          alias: 'p',
        ),
      ],
      groupBy: [
        AggregateGroupKey(
          'o.orderedAt',
          unit: EnumAggregateGroupUnit.month,
          utcOffsetMinutes: 540,
          alias: 'month',
        ),
        AggregateGroupKey('productId'),
      ],
      aggregations: [
        Aggregation(
          EnumAggregateType.sum_,
          fields: ['quantity', 'unitPrice'],
          vType: EnumValueType.decimal_,
          alias: 'sales',
        ),
        Aggregation(
          EnumAggregateType.sum_,
          fields: ['quantity', 'p.unitsPerSet'],
          vType: EnumValueType.decimal_,
          alias: 'units',
        ),
      ],
      sortObj: MultiSort([
        SingleSort(field: 'month', reversed: true),
        SingleSort(field: 'productId'),
      ]),
    ).build();
    final r = db.executeQuery(Query.fromDict(q.toDict()));
    expect(r.isSuccess, true, reason: r.errorMessage);
    expect(r.hitCount, 4);
    expect(r.result, [
      {'month': '2026-11', 'productId': 'P2', 'sales': '0', 'units': '10'},
      {'month': '2026-10', 'productId': 'P1', 'sales': '301.50', 'units': '18'},
      {'month': '2026-10', 'productId': 'P2', 'sales': '0', 'units': '30'},
    ]);
  });

  test('period labels', () {
    AggregateGroupKey k(
      EnumAggregateGroupUnit unit, {
      int? offset,
      int? weekStart,
      int? startMonth,
    }) => AggregateGroupKey(
      'at',
      unit: unit,
      utcOffsetMinutes: offset,
      weekStart: weekStart,
      startMonth: startMonth,
    );
    const wed = '2026-10-07T12:00:00Z';
    expect(_labels([wed], k(EnumAggregateGroupUnit.week)), ['2026-10-05']);
    expect(_labels([wed], k(EnumAggregateGroupUnit.week, weekStart: 7)), [
      '2026-10-04',
    ]);
    expect(_labels([wed], k(EnumAggregateGroupUnit.week, weekStart: 3)), [
      '2026-10-07',
    ]);
    expect(_labels(['2026-01-01T00:00:00Z'], k(EnumAggregateGroupUnit.week)), [
      '2025-12-29',
    ]);
    expect(
      _labels([
        '2026-01-01T03:00:00Z',
        null,
      ], k(EnumAggregateGroupUnit.day, offset: -300)),
      ['2025-12-31', null],
    );
    expect(
      _labels([
        '2026-02-10T00:00:00Z',
        '2026-11-10T00:00:00Z',
      ], k(EnumAggregateGroupUnit.quarter, startMonth: 4)),
      ['2026-01/2026-03', '2026-10/2026-12'],
    );
    expect(
      _labels([
        '2026-01-10T00:00:00Z',
      ], k(EnumAggregateGroupUnit.quarter, startMonth: 2)),
      ['2025-11/2026-01'],
    );
    expect(
      _labels([
        '2026-02-10T00:00:00Z',
      ], k(EnumAggregateGroupUnit.year, startMonth: 4)),
      ['2025-04/2026-03'],
    );
    expect(_labels(['2026-02-10T00:00:00Z'], k(EnumAggregateGroupUnit.year)), [
      '2026-01/2026-12',
    ]);
  });

  test('errors', () {
    final db = _salesDb();
    String? err(List<AggregateJoin> joins, {List<AggregateGroupKey>? groupBy}) {
      final r = db.executeQuery(
        QueryBuilder.aggregate(
          target: 'order_items',
          joins: joins,
          groupBy: groupBy,
          aggregations: [Aggregation(EnumAggregateType.count_)],
        ).build(),
      );
      expect(r.isSuccess, false);
      return r.errorMessage;
    }

    AggregateJoin j(String collection, String localKey, String foreignKey) =>
        AggregateJoin(
          collection: collection,
          localKey: localKey,
          foreignKey: foreignKey,
          alias: 'x',
        );
    expect(
      err([j('none', 'productId', 'id')]),
      "The joined collection does not exist: 'none'",
    );
    expect(
      err([j('products', 'orderId', 'id')]),
      "No item in 'products' has the same id as 'orderId' (join alias: 'x').",
    );
    expect(
      err([j('order_items', 'productId', 'productId')]),
      "More than one item in 'order_items' has the same productId as "
      "'productId' (join alias: 'x').",
    );
    expect(
      err([j('products', 'none', 'id')]),
      "The value of 'none' is null (join alias: 'x').",
    );
    expect(
      err([
        AggregateJoin(
          collection: 'products',
          localKey: 'productId',
          foreignKey: 'id',
          alias: 'quantity',
        ),
      ]),
      "The join alias 'quantity' is the same as a field of the item.",
    );
    expect(
      err(
        [],
        groupBy: [
          AggregateGroupKey(
            'orderId',
            unit: EnumAggregateGroupUnit.month,
            weekStart: 1,
          ),
        ],
      ),
      "weekStart can be used only with week.",
    );
    expect(
      err(
        [],
        groupBy: [
          AggregateGroupKey('orderId', unit: EnumAggregateGroupUnit.month),
        ],
      ),
      "Cannot read the value of field 'orderId' as a date-time.",
    );
  });

  test('joined collections require the read permission', () {
    final db = _salesDb();
    final q = QueryBuilder.aggregate(
      target: 'order_items',
      joins: [
        AggregateJoin(
          collection: 'products',
          localKey: 'productId',
          foreignKey: 'id',
          alias: 'p',
        ),
      ],
      aggregations: [Aggregation(EnumAggregateType.count_)],
    ).build();
    final aggregateOnly = {
      'order_items': Permission([EnumQueryType.aggregate]),
    };
    expect(
      db.executeQuery(q, collectionPermissions: aggregateOnly).isSuccess,
      false,
    );
    expect(
      db
          .executeQuery(
            q,
            collectionPermissions: {
              ...aggregateOnly,
              'products': Permission([EnumQueryType.search]),
            },
          )
          .isSuccess,
      true,
    );
  });
}
