import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('permission test', () {
    DeltaTraceDatabase db = DeltaTraceDatabase();
    Query q = QueryBuilder.clear(
      target: "user",
      mustAffectAtLeastOne: false,
    ).build();
    TransactionQuery tq = TransactionQuery(queries: [q]);
    final r1 = db.executeQuery(q, collectionPermissions: null);
    final r2 = db.executeQuery(q, collectionPermissions: {});
    final r3 = db.executeQuery(
      q,
      collectionPermissions: {"user": Permission([])},
    );
    final r4 = db.executeQuery(
      q,
      collectionPermissions: {
        "user": Permission([EnumQueryType.add]),
      },
    );
    final r5 = db.executeQuery(
      q,
      collectionPermissions: {
        "user": Permission([EnumQueryType.clear]),
      },
    );
    final tr1 = db.executeTransactionQuery(tq, collectionPermissions: null);
    final tr2 = db.executeTransactionQuery(tq, collectionPermissions: {});
    final tr3 = db.executeTransactionQuery(
      tq,
      collectionPermissions: {"user": Permission([])},
    );
    final tr4 = db.executeTransactionQuery(
      tq,
      collectionPermissions: {
        "user": Permission([EnumQueryType.add]),
      },
    );
    final tr5 = db.executeTransactionQuery(
      tq,
      collectionPermissions: {
        "user": Permission([EnumQueryType.clear]),
      },
    );
    expect(r1.isSuccess, true);
    expect(r2.isSuccess, false);
    expect(r3.isSuccess, false);
    expect(r4.isSuccess, false);
    expect(r5.isSuccess, true);
    expect(tr1.isSuccess, true);
    expect(tr2.isSuccess, false);
    expect(tr3.isSuccess, false);
    expect(tr4.isSuccess, false);
    expect(tr5.isSuccess, true);
  });
}
