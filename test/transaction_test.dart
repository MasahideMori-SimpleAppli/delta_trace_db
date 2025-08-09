import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:test/test.dart';

class User extends CloneableFile {
  final String id;
  final String name;
  final int age;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> nestedObj;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
    required this.nestedObj,
  });

  static User fromDict(Map<String, dynamic> src) => User(
    id: src['id'],
    name: src['name'],
    age: src['age'],
    createdAt: DateTime.parse(src['createdAt']),
    updatedAt: DateTime.parse(src['updatedAt']),
    nestedObj: src['nestedObj'],
  );

  @override
  Map<String, dynamic> toDict() => {
    'id': id,
    'name': name,
    'age': age,
    'createdAt': createdAt.toIso8601String(),
    // This will automatically update the update date.
    'updatedAt': DateTime.now().toIso8601String(),
    'nestedObj': {...nestedObj},
  };

  @override
  User clone() {
    return User.fromDict(toDict());
  }
}

void main() {
  test('transaction query test', () {
    final now = DateTime.now();
    final db = DeltaTraceDatabase();
    List<User> users = [
      User(
        id: '1',
        name: 'サンプル太郎',
        age: 25,
        createdAt: now.add(Duration(days: 0)),
        updatedAt: now.add(Duration(days: 0)),
        nestedObj: {},
      ),
      User(
        id: '2',
        name: 'サンプル次郎',
        age: 28,
        createdAt: now.add(Duration(days: 1)),
        updatedAt: now.add(Duration(days: 1)),
        nestedObj: {},
      ),
      User(
        id: '3',
        name: 'サンプル三郎',
        age: 31,
        createdAt: now.add(Duration(days: 2)),
        updatedAt: now.add(Duration(days: 2)),
        nestedObj: {},
      ),
      User(
        id: '4',
        name: 'サンプル花子',
        age: 17,
        createdAt: now.add(Duration(days: 3)),
        updatedAt: now.add(Duration(days: 3)),
        nestedObj: {},
      ),
    ];
    // add
    final Query q1 = QueryBuilder.add(target: 'users1', addData: users).build();
    final Query q2 = QueryBuilder.add(target: 'users2', addData: users).build();
    QueryResult<User> _ = db.executeQuery<User>(q1);
    QueryResult<User> _ = db.executeQuery<User>(q2);
    // Failed transactions
    final TransactionQuery tq1 = TransactionQuery(
      queries: [
        QueryBuilder.update(
          target: 'users1',
          // type error
          queryNode: FieldEquals("id", 3),
          overrideData: {"id": 5},
          returnData: true,
          mustAffectAtLeastOne: true,
        ).build(),
        QueryBuilder.clear(target: 'users2').build(),
      ],
    );
    QueryExecutionResult result = db.executeQueryObject(tq1);
    expect(result.isSuccess, false);
    expect(db.collection('users2').length != 0, true);
    // Success　transactions
    final TransactionQuery tq2 = TransactionQuery(
      queries: [
        QueryBuilder.update(
          target: 'users1',
          queryNode: FieldEquals("id", "3"),
          overrideData: {"id": "5"},
          returnData: true,
          mustAffectAtLeastOne: true,
        ).build(),
        QueryBuilder.clear(target: 'users2').build(),
      ],
    );
    QueryExecutionResult result2 = db.executeQueryObject(tq2);
    expect(result2.isSuccess, true);
    expect(db.collection('users2').length == 0, true);
  });
}
