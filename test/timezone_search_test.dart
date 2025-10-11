import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('timezone search test', () {
    final db = DeltaTraceDatabase();
    final q1 = RawQueryBuilder.add(
      target: "user",
      rawAddData: [
        {"id": "0", "time": "2025-10-11T18:30:00"}, // local time
        {"id": "1", "time": "2025-10-11T18:30:00+09:00"}, // jst timezone
        {"id": "2", "time": "2025-10-11T09:30:00Z"}, // utc
      ],
    ).build();
    db.executeQuery(q1);
    // search by local time.
    final q2 = RawQueryBuilder.search(
      target: "user",
      queryNode: FieldEquals("time", DateTime(2025, 10, 11, 18, 30)),
    ).build();
    final r2 = db.executeQuery(q2);
    // hit only local time items.
    expect(r2.isSuccess == true, true);
    expect(r2.result.length == 1, true);
    expect(r2.result.first["id"] == "0", true);
    // search by utc(with timezone).
    final q3 = RawQueryBuilder.search(
      target: "user",
      queryNode: FieldEquals("time", DateTime(2025, 10, 11, 18, 30).toUtc()),
    ).build();
    final r3 = db.executeQuery(q3);
    // Only items with a time zone attached will be hit.
    expect(r3.isSuccess == true, true);
    expect(r3.result.length == 2, true);
    expect(r3.result.first["id"] == "1", true);
    expect(r3.result.last["id"] == "2", true);
  });
}
