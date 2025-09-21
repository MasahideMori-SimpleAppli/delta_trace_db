import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('searchOne test', () {
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
    final q2 = RawQueryBuilder.searchOne(
      target: "user",
      queryNode: FieldEquals("name", "a"),
    ).build();
    final r2 = db.executeQuery(q2);
    expect(r2.isSuccess, true);
    expect(r2.result.length == 1, true);
    expect(r2.hitCount == 1, true);
    expect(r2.result.first["id"] == 0, true);
  });
}
