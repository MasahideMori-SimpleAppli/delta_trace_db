import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('version up test', () {
    try {
      final qr = QueryResult.fromDict({
        "className": "QueryResult",
        "version": "5",
        "isSuccess": true,
        // target が無しでも復元できるか。互換性の確認。
        // "target" : "abc",
        "type": EnumQueryType.add.name,
        "result": [],
        "dbLength": 0,
        "updateCount": 0,
        "hitCount": 0,
        "errorMessage": null,
      });
      expect(qr.target == "", true);
    } catch (e) {
      expect(false, true);
    }
  });
}
