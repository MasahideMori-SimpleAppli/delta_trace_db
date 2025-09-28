import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:test/test.dart';

class User extends CloneableFile {
  final int age;

  User({required this.age});

  static User fromDict(Map<String, dynamic> src) => User(age: src['age']);

  @override
  Map<String, dynamic> toDict() => {'age': age};

  @override
  User clone() {
    return User.fromDict(toDict());
  }
}

void main() {
  test('get_all test', () {
    final int recordsCount = 100;
    // データベース作成とデータ追加
    final db = DeltaTraceDatabase();
    List<User> users = [];
    for (int i = 0; i < recordsCount; i++) {
      users.add(User(age: i));
    }
    final Query q1 = QueryBuilder.add(target: 'users', addData: users).build();
    final QueryResult<User> r1 = db.executeQuery<User>(q1);
    expect(r1.isSuccess, true);
    expect(r1.dbLength == recordsCount, true);

    final Query q2 = QueryBuilder.getAll(target: 'users').build();
    final QueryResult<User> r2 = db.executeQuery<User>(q2);
    expect(r2.result.length == recordsCount, true);

    final Query q3 = QueryBuilder.getAll(target: 'users', limit: 10).build();
    final QueryResult<User> r3 = db.executeQuery<User>(q3);
    expect(r3.result.length == 10, true);

    final Query q4 = QueryBuilder.getAll(
      target: 'users',
      limit: 10,
      offset: 10,
    ).build();
    final QueryResult<User> r4 = db.executeQuery<User>(q4);
    expect(r4.result.length == 10, true);
    expect(r4.result.last["age"] == 19, true);

    final Query q5 = QueryBuilder.getAll(
      target: 'users',
      limit: 10,
      startAfter: User(age: 9).toDict(),
    ).build();
    final QueryResult<User> r5 = db.executeQuery<User>(q5);
    expect(r5.result.length == 10, true);
    expect(r5.result.last["age"] == 19, true);

    final Query q6 = QueryBuilder.getAll(
      target: 'users',
      limit: 10,
      endBefore: User(age: 10).toDict(),
    ).build();
    final QueryResult<User> r6 = db.executeQuery<User>(q6);
    expect(r6.result.length == 10, true);
    expect(r6.result.last["age"] == 9, true);

    final Query q7 = QueryBuilder.getAll(
      target: 'users',
      limit: 10,
      offset: 20,
      sortObj: SingleSort(field: "age", reversed: true),
    ).build();
    final QueryResult<User> r7 = db.executeQuery<User>(q7);
    expect(r7.result.length == 10, true);
    expect(r7.result.last["age"] == 70, true);
  });
}
