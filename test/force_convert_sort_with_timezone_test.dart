import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('force convert sort with timezone test', () {
    final db = DeltaTraceDatabase();
    final q1 = RawQueryBuilder.add(
      target: "user",
      rawAddData: [
        {"id": "0", "time": "2025-10-11T18:30:00+09:00"}, // jst timezone
        {"id": "1", "time": "2025-10-11T18:30:00+09:00"}, // jst timezone
        {"id": "2", "time": "2025-10-11T09:30:00Z"}, // utc
      ],
    ).build();
    db.executeQuery(q1);
    // search by utc(with timezone, force convert sort).
    final q2 = RawQueryBuilder.search(
      target: "user",
      queryNode: FieldEquals("time", DateTime(2025, 10, 11, 18, 30).toUtc()),
      sortObj: SingleSort(field: "time", vType: EnumValueType.datetime_),
    ).build();
    final r2 = db.executeQuery(q2);
    expect(r2.isSuccess == true, true);
    expect(r2.result.length == 3, true);
    final ids = r2.result.map((e) => e["id"]).toList();
    expect(ids.toSet(), {"0", "1", "2"});
  });
}
