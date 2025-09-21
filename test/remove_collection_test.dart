import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('removeCollection test', () {
    final db = DeltaTraceDatabase();
    final q1 = RawQueryBuilder.add(
      target: "user",
      rawAddData: [
        {"id": -1, "name": "a"},
        {"id": -1, "name": "a"},
      ],
      serialKey: "id",
    ).build();
    db.executeQuery(q1);
    expect(db.collection("user").length == 2, true);
    final q2 = RawQueryBuilder.removeCollection(target: "user").build();
    final r2 = db.executeQuery(q2);
    expect(r2.isSuccess, true);
    expect(db.findCollection("user") == null, true);
    final q3 = RawQueryBuilder.removeCollection(
      target: "user",
      mustAffectAtLeastOne: true,
    ).build();
    final r3 = db.executeQuery(q3);
    expect(r3.isSuccess, false);
    expect(db.findCollection("user") == null, true);
    // 許可されないトランザクション
    final tq1 = TransactionQuery(queries: [q3]);
    final tr1 = db.executeTransactionQuery(tq1);
    expect(tr1.isSuccess, false);
    expect(
      tr1.errorMessage ==
          "The query contains a type that is not permitted to be executed within a transaction.",
      true,
    );
  });
}
