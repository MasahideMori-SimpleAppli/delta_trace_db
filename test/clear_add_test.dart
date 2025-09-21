import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('clearAdd test', () {
    final db = DeltaTraceDatabase();
    final q1 = RawQueryBuilder.add(
      target: "user",
      rawAddData: [
        {"id": -1},
        {"id": -1},
      ],
      serialKey: "id",
    ).build();
    db.executeQuery(q1);
    expect(db.collection("user").length == 2, true);
    final q2 = RawQueryBuilder.clearAdd(
      target: "user",
      rawAddData: [
        {"id": -1},
        {"id": -1},
        {"id": -1},
      ],
      serialKey: "nonID",
    ).build();
    final r2 = db.executeQuery(q2);
    expect(db.collection("user").length == 2, true);
    expect(r2.isSuccess == false, true);
    final q3 = RawQueryBuilder.clearAdd(
      target: "user",
      rawAddData: [
        {"id": -1},
        {"id": -1},
        {"id": -1},
      ],
      serialKey: "id",
      resetSerial: true,
    ).build();
    final r3 = db.executeQuery(q3);
    expect(db.collection("user").length == 3, true);
    expect(r3.isSuccess, true);
    expect(db.collection("user").raw[0]["id"] == 0, true);
    final q4 = RawQueryBuilder.clearAdd(
      target: "user",
      rawAddData: [
        {"id": -1},
        {"id": -1},
        {"id": -1},
      ],
      serialKey: "id",
      resetSerial: false,
    ).build();
    final r4 = db.executeQuery(q4);
    expect(db.collection("user").length == 3, true);
    expect(r4.isSuccess, true);
    expect(db.collection("user").raw[0]["id"] == 3, true);
  });
}
