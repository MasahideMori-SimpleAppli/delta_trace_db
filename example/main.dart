import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:flutter/material.dart';

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
    createdAt: DateTime.fromMillisecondsSinceEpoch(src['createdAt']),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(src['updatedAt']),
    nestedObj: src['nestedObj'],
  );

  @override
  Map<String, dynamic> toDict() => {
    'id': id,
    'name': name,
    'age': age,
    'createdAt': createdAt.millisecondsSinceEpoch,
    // This will automatically update the update date.
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
    'nestedObj': {...nestedObj},
  };

  @override
  User clone() {
    return User.fromDict(toDict());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.now();
  final db = DeltaTraceDatabase();

  // add
  final Query q1 = QueryBuilder.add(
    target: 'users',
    addData: [
      User(
        id: '1',
        name: 'sampleA',
        age: 25,
        createdAt: now,
        updatedAt: now,
        nestedObj: {"a": "test", "b": 1},
      ),
      User(
        id: '2',
        name: 'sampleB',
        age: 28,
        createdAt: now,
        updatedAt: now,
        nestedObj: {"a": "test", "b": 1},
      ),
      User(
        id: '3',
        name: 'sampleC',
        age: 31,
        createdAt: now,
        updatedAt: now,
        nestedObj: {"a": "text", "b": 2},
      ),
      User(
        id: '4',
        name: 'sampleD',
        age: 17,
        createdAt: now,
        updatedAt: now,
        nestedObj: {"a": "text", "b": 3},
      ),
    ],
  ).build();
  // If the query is processed on the server, it can be serialized.
  // final jsonMap = q1.toDict();
  debugPrint("// add");
  final QueryResult<User> addResult = db.executeQuery<User>(q1);
  debugPrint("dbLength:${addResult.dbLength}");

  // search
  final Query q2 = QueryBuilder.search(
    target: 'users',
    queryNode: FieldStartsWith("name", "sample"),
    sortObj: SingleSort(field: 'age'),
    limit: 2,
  ).build();
  final QueryResult<User> r2 = db.executeQuery<User>(q2);
  // convert to class
  final List<User> searchResult = r2.convert(User.fromDict);
  debugPrint("// search");
  debugPrint("return:${searchResult.length}");
  debugPrint("hitCount:${r2.hitCount}");
  for (User i in searchResult) {
    debugPrint(i.name);
  }
  // paging option
  final Query q2Paging = QueryBuilder.search(
    target: 'users',
    queryNode: FieldStartsWith("name", "sample"),
    sortObj: SingleSort(field: 'age'),
    limit: 2,
    startAfter: r2.result.last,
  ).build();
  final QueryResult<User> r2Paging = db.executeQuery<User>(q2Paging);
  final List<User> searchResultPaging = r2Paging.convert(User.fromDict);
  debugPrint("// search (paging)");
  debugPrint("return:${searchResultPaging.length}");
  debugPrint("hitCount:${r2Paging.hitCount}");
  for (User i in searchResultPaging) {
    debugPrint(i.name);
  }

  // nested param search
  // You can access nested parameters by specifying variables separated by ".".
  final Query q2Nested = QueryBuilder.search(
    target: 'users',
    queryNode: FieldEquals("nestedObj.b", 1),
    sortObj: SingleSort(field: 'age'),
  ).build();
  final QueryResult<User> r2Nested = db.executeQuery<User>(q2Nested);
  // convert to class
  final List<User> searchNestedResult = r2Nested.convert(User.fromDict);
  debugPrint("// nested param search");
  debugPrint("return:${searchNestedResult.length}");
  debugPrint("hitCount:${r2Nested.hitCount}");
  for (User i in searchNestedResult) {
    debugPrint(i.name);
  }

  // update
  final Query q3 = QueryBuilder.update(
    target: 'users',
    queryNode: OrNode([
      FieldEquals('name', 'sampleA'),
      FieldEquals('name', 'sampleD'),
    ]),
    overrideData: {'age': 26},
    returnData: true,
    sortObj: SingleSort(field: 'id'),
  ).build();
  final QueryResult<User> r3 = db.executeQuery<User>(q3);
  // convert to class
  final List<User> updateResult = r3.convert(User.fromDict);
  debugPrint("// update");
  debugPrint("updateCount:${r3.updateCount}");
  for (User i in updateResult) {
    debugPrint(i.toDict().toString());
  }

  // delete
  final Query q4 = QueryBuilder.delete(
    target: 'users',
    queryNode: FieldEquals("name", "sampleD"),
    sortObj: SingleSort(field: 'id'),
    returnData: false,
  ).build();
  final QueryResult<User> deleteResult = db.executeQuery<User>(q4);
  debugPrint("// delete");
  debugPrint("dbLength:${deleteResult.dbLength}");

  // save and load
  // You can save it using your favorite package or using standard input and
  // output.
  // This package simply converts the contents of the DB into a Map,
  // so it can be extended in various ways, for example to perform encryption.
  final Map<String, dynamic> jsonMap = db.toDict();

  // Restoring the database can be completed simply by loading the map.
  final DeltaTraceDatabase resumedDB = DeltaTraceDatabase.fromDict(jsonMap);
  debugPrint("resumedDB users length:${resumedDB.collection('users').length}");
}
