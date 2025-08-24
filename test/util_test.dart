import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('util_query test', () {
    Query q = QueryBuilder.clear(target: "user").build();
    TransactionQuery tq = TransactionQuery(queries: [q]);
    final r1 = UtilQuery.convertFromJson(q.toDict());
    final r2 = UtilQuery.convertFromJson(tq.toDict());
    expect(r1 is Query, true);
    expect(r2 is TransactionQuery, true);
  });
}
