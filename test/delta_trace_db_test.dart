import 'dart:convert';
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

class User2 extends CloneableFile {
  final String id;
  final String name;
  final int age;
  final String gender;

  User2({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
  });

  static User2 fromDict(Map<String, dynamic> src) => User2(
    id: src['id'],
    name: src['name'],
    age: src['age'],
    gender: src['gender'],
  );

  @override
  Map<String, dynamic> toDict() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
  };

  @override
  User2 clone() {
    return User2.fromDict(toDict());
  }
}

class User3 extends CloneableFile {
  final String serialID;
  final String name;
  final int age;
  final String gender;

  User3({
    required this.serialID,
    required this.name,
    required this.age,
    required this.gender,
  });

  static User3 fromDict(Map<String, dynamic> src) => User3(
    serialID: src['serialID'],
    name: src['name'],
    age: src['age'],
    gender: src['gender'],
  );

  @override
  Map<String, dynamic> toDict() => {
    'serialID': serialID,
    'name': name,
    'age': age,
    'gender': gender,
  };

  @override
  User3 clone() {
    return User3.fromDict(toDict());
  }
}

void main() {
  test('DB basic operation test', () {
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
    final Query q1 = QueryBuilder.add(target: 'users', addData: users).build();
    QueryResult<User> r1 = db.executeQuery<User>(Query.fromDict(q1.toDict()));
    r1 = QueryResult.fromDict(r1.toDict()); // QueryResult serialize test.
    expect(r1.isNoErrors, true);
    expect(r1.dbLength == 4, true);

    // clearAdd
    final Query q1ex = QueryBuilder.clearAddAll(
      target: 'users',
      addData: users,
    ).build();
    final QueryResult<User> r1ex = db.executeQuery<User>(
      Query.fromDict(q1ex.toDict()),
    );
    expect(r1ex.isNoErrors, true);
    expect(r1ex.dbLength == 4, true);

    // search
    final Query q2 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldStartsWith("name", "サンプル"),
      sortObj: SingleSort(field: 'age', reversed: true),
      limit: 2,
    ).build();
    final QueryResult<User> r2 = db.executeQuery<User>(
      Query.fromDict(q2.toDict()),
    );
    expect(r2.dbLength == 4, true);
    expect(r2.hitCount == 4, true);
    List<User> result2 = r2.convert(User.fromDict);
    expect(result2.length == 2, true);
    expect(result2[0].name == 'サンプル三郎', true);

    // query result serialize test
    final QueryResult r2S = db.executeQuery(q2);
    final resumeResult = QueryResult<User>.fromDict(
      jsonDecode(jsonEncode(r2S.toDict())),
    );
    expect(resumeResult.dbLength == 4, true);
    expect(resumeResult.hitCount == 4, true);
    List<User> result2Resume = resumeResult.convert(User.fromDict);
    expect(result2Resume.length == 2, true);
    expect(result2Resume[0].name == 'サンプル三郎', true);

    // search by datetime
    final Query q2Dt = QueryBuilder.search(
      target: 'users',
      queryNode: AndNode([
        FieldGreaterThanOrEqual("createdAt", now.add(Duration(days: 1))),
        FieldLessThanOrEqual("createdAt", now.add(Duration(days: 2))),
      ]),
      sortObj: SingleSort(field: 'createdAt', reversed: true),
    ).build();
    final QueryResult<User> r2_dt = db.executeQuery<User>(
      Query.fromDict(q2Dt.toDict()),
    );
    expect(r2_dt.dbLength == 4, true);
    expect(r2_dt.hitCount == 2, true);
    List<User> result2_dt = r2_dt.convert(User.fromDict);
    expect(result2_dt.length == 2, true);
    expect(result2_dt[0].name == 'サンプル三郎', true);
    expect(result2_dt[1].name == 'サンプル次郎', true);

    // paging
    final Query q3 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldStartsWith('name', 'サンプル'),
      sortObj: SingleSort(field: 'age', reversed: true),
      limit: 2,
      startAfter: r2.result.last,
    ).build();
    final QueryResult<User> r3 = db.executeQuery<User>(
      Query.fromDict(q3.toDict()),
    );
    expect(r3.dbLength == 4, true);
    expect(r3.hitCount == 4, true);
    List<User> result3 = r3.convert(User.fromDict);
    expect(result3.length == 2, true);
    expect(result3[0].name == 'サンプル太郎', true);
    expect(result3[1].name == 'サンプル花子', true);
    // pagingByOffset
    final Query q3Offset = QueryBuilder.search(
      target: 'users',
      queryNode: FieldStartsWith('name', 'サンプル'),
      sortObj: SingleSort(field: 'age', reversed: true),
      limit: 2,
      offset: 2,
    ).build();
    final QueryResult<User> r3Offset = db.executeQuery<User>(
      Query.fromDict(q3Offset.toDict()),
    );
    expect(r3Offset.dbLength == 4, true);
    expect(r3Offset.hitCount == 4, true);
    List<User> result3Offset = r3Offset.convert(User.fromDict);
    expect(result3Offset.length == 2, true);
    expect(result3Offset[0].name == 'サンプル太郎', true);
    expect(result3Offset[1].name == 'サンプル花子', true);

    // update
    final Query q4 = QueryBuilder.update(
      target: 'users',
      queryNode: OrNode([
        FieldEquals('name', 'サンプル太郎'),
        FieldEquals('name', 'サンプル花子'),
      ]),
      overrideData: {'age': 26},
      returnData: true,
      sortObj: SingleSort(field: 'id'),
    ).build();
    final QueryResult<User> r4 = db.executeQuery<User>(
      Query.fromDict(q4.toDict()),
    );
    expect(r4.dbLength == 4, true);
    expect(r4.updateCount == 2, true);
    expect(r4.hitCount == 2, true);
    List<User> result4 = r4.convert(User.fromDict);
    expect(result4[0].name == 'サンプル太郎', true);
    expect(result4[0].age == 26, true);
    expect(result4[1].name == 'サンプル花子', true);
    expect(result4[1].age == 26, true);
    final Query q5 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldStartsWith("age", "26"),
      sortObj: SingleSort(field: 'id'),
      limit: 2,
    ).build();
    final QueryResult<User> r5 = db.executeQuery<User>(
      Query.fromDict(q5.toDict()),
    );
    List<User> result5 = r5.convert(User.fromDict);
    expect(result5[0].name == 'サンプル太郎', true);
    expect(result5[0].age == 26, true);
    expect(result5[1].name == 'サンプル花子', true);
    expect(result5[1].age == 26, true);

    // updateOne
    final Query q6 = QueryBuilder.updateOne(
      target: 'users',
      queryNode: FieldEquals('name', 'サンプル花子'),
      overrideData: {'name': 'テスト花子'},
      returnData: true,
    ).build();
    final QueryResult<User> r6 = db.executeQuery<User>(
      Query.fromDict(q6.toDict()),
    );
    expect(r6.dbLength == 4, true);
    expect(r6.updateCount == 1, true);
    expect(r6.hitCount == 1, true);
    List<User> result6 = r6.convert(User.fromDict);
    expect(result6[0].name == 'テスト花子', true);
    expect(result6[0].age == 26, true);
    final Query q7 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldStartsWith("age", "26"),
      sortObj: SingleSort(field: 'id'),
      limit: 2,
    ).build();
    final QueryResult<User> r7 = db.executeQuery<User>(
      Query.fromDict(q7.toDict()),
    );
    List<User> result7 = r7.convert(User.fromDict);
    expect(result7[0].name == 'サンプル太郎', true);
    expect(result7[0].age == 26, true);
    expect(result7[1].name == 'テスト花子', true);
    expect(result7[1].age == 26, true);

    // delete
    final Query q8 = QueryBuilder.delete(
      target: 'users',
      queryNode: FieldEquals("name", "テスト花子"),
      sortObj: SingleSort(field: 'id'),
      returnData: true,
    ).build();
    final QueryResult<User> r8 = db.executeQuery<User>(
      Query.fromDict(q8.toDict()),
    );
    expect(r8.dbLength == 3, true);
    expect(r8.updateCount == 1, true);
    expect(r8.hitCount == 1, true);
    List<User> result8 = r8.convert(User.fromDict);
    expect(result8[0].name == 'テスト花子', true);
    expect(result8[0].age == 26, true);
    final Query q9 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldStartsWith("name", "テスト花子"),
      sortObj: SingleSort(field: 'id'),
      limit: 2,
    ).build();
    final QueryResult<User> r9 = db.executeQuery<User>(
      Query.fromDict(q9.toDict()),
    );
    expect(r9.dbLength == 3, true);
    expect(r9.updateCount == 0, true);
    expect(r9.hitCount == 0, true);
    List<User> result9 = r9.convert(User.fromDict);
    expect(result9.isEmpty, true);

    // conformToTemplate (User to User2)
    final Query q10 = QueryBuilder.conformToTemplate(
      target: 'users',
      template: User2(id: '5', name: 'NoData', age: -1, gender: 'NoData'),
    ).build();
    final QueryResult<User2> r10 = db.executeQuery<User2>(
      Query.fromDict(q10.toDict()),
    );
    expect(r10.dbLength == 3, true);
    final Query q11 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldStartsWith("name", "サンプル"),
      sortObj: SingleSort(field: 'id'),
      limit: 2,
    ).build();
    final QueryResult<User2> r11 = db.executeQuery<User2>(
      Query.fromDict(q11.toDict()),
    );
    List<User2> result11 = r11.convert(User2.fromDict);
    expect(result11[0].gender == "NoData", true);

    // renameField
    final Query q12 = QueryBuilder.renameField(
      target: 'users',
      renameBefore: 'id',
      renameAfter: 'serialID',
      returnData: true,
    ).build();
    final QueryResult<User3> r12 = db.executeQuery<User3>(
      Query.fromDict(q12.toDict()),
    );
    expect(r12.dbLength == 3, true);
    expect(r12.updateCount == 3, true);
    expect(r12.hitCount == 3, true);
    List<User3> _ = r12.convert(User3.fromDict);

    // count
    final Query q13 = QueryBuilder.count(target: 'users').build();
    final QueryResult<User3> r13 = db.executeQuery<User3>(
      Query.fromDict(q13.toDict()),
    );
    expect(r13.dbLength == 3, true);
    expect(r13.updateCount == 0, true);
    expect(r13.hitCount == 3, true);

    // clear
    final Query q14 = QueryBuilder.clear(target: 'users').build();
    final QueryResult<User3> r14 = db.executeQuery<User3>(
      Query.fromDict(q14.toDict()),
    );
    expect(r14.dbLength == 0, true);
    expect(r14.updateCount == 3, true);
    expect(r14.hitCount == 3, true);
  });

  test('save and load test', () {
    final now = DateTime.now();
    // データベース作成とデータ追加
    final db = DeltaTraceDatabase();
    // add
    final Query q = QueryBuilder.add(
      target: 'users',
      addData: [
        User(
          id: '1',
          name: 'サンプル太郎',
          age: 25,
          createdAt: now,
          updatedAt: now,
          nestedObj: {},
        ),
        User(
          id: '2',
          name: 'サンプル次郎',
          age: 28,
          createdAt: now,
          updatedAt: now,
          nestedObj: {},
        ),
        User(
          id: '3',
          name: 'サンプル三郎',
          age: 31,
          createdAt: now,
          updatedAt: now,
          nestedObj: {},
        ),
        User(
          id: '4',
          name: 'サンプル花子',
          age: 17,
          createdAt: now,
          updatedAt: now,
          nestedObj: {},
        ),
      ],
      cause: Cause(
        serial: "1",
        who: Actor(
          EnumActorType.system,
          "1",
          ["tester"],
          ["users:write:all"],
          context: {"otherData": "test"},
        ),
        when: TemporalTrace(
          nodes: [TimestampNode(timestamp: DateTime.now(), location: "system")],
        ),
        what: "The test of serialize and deserialize.",
        why: "test",
        from: "test",
      ),
    ).build();
    // json convert test
    String jsonStr = jsonEncode(q.toDict());
    expect(
      q.toDict().toString() ==
          Query.fromDict(jsonDecode(jsonStr)).toDict().toString(),
      true,
    );
    final QueryResult<User> r1 = db.executeQuery<User>(q);
    expect(r1.isNoErrors, true);
    // シリアライズと復元
    final usersDB = db.toDict();
    final db2 = DeltaTraceDatabase.fromDict(usersDB);
    final users = db.collection('users');
    final loadedUsers = db2.collection('users');
    // ユーザー数が一致している
    expect(loadedUsers.length, equals(4));
    // IDごとに取得・比較
    for (int i = 0; i < users.length; i++) {
      final originalMap = users.raw[i];
      final loadedMap = loadedUsers.raw[i];
      final original = User.fromDict(originalMap);
      final loaded = User.fromDict(loadedMap);
      expect(loaded.id, equals(original.id));
      expect(loaded.name, equals(original.name));
      expect(loaded.age, equals(original.age));
      expect(
        loaded.createdAt.toIso8601String(),
        equals(original.createdAt.toIso8601String()),
      );
    }
  });

  test('complex search test', () {
    final now = DateTime.now();
    // データベース作成とデータ追加
    final db = DeltaTraceDatabase();
    // add
    final Query q1 = QueryBuilder.add(
      target: 'users',
      addData: [
        User(
          id: '1',
          name: 'サンプル太郎',
          age: 25,
          createdAt: now,
          updatedAt: now,
          nestedObj: {"a": "test", "b": 1},
        ),
        User(
          id: '2',
          name: 'サンプル次郎',
          age: 28,
          createdAt: now,
          updatedAt: now,
          nestedObj: {"a": "test", "b": 1},
        ),
        User(
          id: '3',
          name: 'サンプル三郎',
          age: 31,
          createdAt: now,
          updatedAt: now,
          nestedObj: {"a": "text", "b": 2},
        ),
        User(
          id: '4',
          name: 'サンプル花子',
          age: 17,
          createdAt: now,
          updatedAt: now,
          nestedObj: {"a": "text", "b": 3},
        ),
      ],
    ).build();
    final QueryResult<User> r1 = db.executeQuery<User>(q1);
    expect(r1.isNoErrors, true);
    // ネストされたオブジェクトの検索（文字列）
    final Query q2 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldEquals("nestedObj.a", "test"),
      sortObj: SingleSort(field: 'id', reversed: false),
    ).build();
    final QueryResult<User> r2 = db.executeQuery<User>(q2);
    expect(r2.hitCount == 2, true);
    expect(r2.result.length == 2, true);
    List<User> result2 = r2.convert(User.fromDict);
    expect(result2[0].name == "サンプル太郎", true);
    expect(result2[1].name == "サンプル次郎", true);
    // ネストされたオブジェクトの検索（数値）
    final Query q3 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldLessThan("nestedObj.b", 2),
      sortObj: SingleSort(field: 'id', reversed: false),
    ).build();
    final QueryResult<User> r3 = db.executeQuery<User>(q3);
    expect(r3.hitCount == 2, true);
    expect(r3.result.length == 2, true);
    List<User> result3 = r3.convert(User.fromDict);
    expect(result3[0].name == "サンプル太郎", true);
    expect(result3[1].name == "サンプル次郎", true);
    // 正規表現での検索
    final Query q4 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldMatchesRegex("name", r'サンプル[太次]郎'),
      sortObj: SingleSort(field: 'id', reversed: false),
    ).build();
    final QueryResult<User> r4 = db.executeQuery<User>(q4);
    expect(r4.hitCount == 2, true);
    expect(r4.result.length == 2, true);
    List<User> result4 = r4.convert(User.fromDict);
    expect(result4[0].name == "サンプル太郎", true);
    expect(result4[1].name == "サンプル次郎", true);
    // 正規表現でのネストされたオブジェクトの検索
    final Query q5 = QueryBuilder.search(
      target: 'users',
      queryNode: FieldMatchesRegex("nestedObj.a", r'te[sx]t'),
      sortObj: SingleSort(field: 'id', reversed: false),
    ).build();
    final QueryResult<User> r5 = db.executeQuery<User>(q5);
    expect(r5.hitCount == 4, true);
    expect(r5.result.length == 4, true);
  });
}
