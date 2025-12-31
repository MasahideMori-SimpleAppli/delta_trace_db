import 'package:collection/collection.dart';
import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:test/test.dart';

class User extends CloneableFile {
  final String id;
  final String name;

  User({required this.id, required this.name});

  static User fromDict(Map<String, dynamic> src) =>
      User(id: src['id'], name: src['name']);

  @override
  Map<String, dynamic> toDict() => {'id': id, 'name': name};

  @override
  User clone() {
    return User.fromDict(toDict());
  }
}

void main() {
  test('transaction query test2', () {
    final db = DeltaTraceDatabase();
    final dbBuf = db.toDict();
    List<User> users = [
      User(id: '1', name: 'サンプル太郎'),
      User(id: '2', name: 'サンプル次郎'),
      User(id: '3', name: 'サンプル三郎'),
      User(id: '4', name: 'サンプル花子'),
    ];
    // add
    final Query q1 = QueryBuilder.add(target: 'users1', addData: users).build();
    // 過去の実装では、失敗するが、新しいコレクションが消えずに残ってしまうトランザクション
    final TransactionQuery tq1 = TransactionQuery(
      queries: [
        QueryBuilder.add(target: 'users1', addData: [q1]).build(),
        QueryBuilder.delete(
          target: 'users1',
          queryNode: FieldEquals("id", "5"),
          mustAffectAtLeastOne: true,
        ).build(),
      ],
    );
    QueryExecutionResult result = db.executeQueryObject(tq1);
    expect(result.isSuccess, false);
    // コレクションが何もない空のままでないとNG
    expect(MapEquality().equals(dbBuf, db.toDict()), true);
    expect(
      (DeltaTraceDatabase.fromDict(dbBuf).raw.keys.length ==
              db.raw.keys.length) &&
          (db.raw.keys.isEmpty),
      true,
    );
  });
}
