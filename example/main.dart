import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:file_state_manager/file_state_manager.dart';

class User extends CloneableFile {
  final int id;
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
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'nestedObj': {...nestedObj},
  };

  @override
  User clone() {
    return User.fromDict(toDict());
  }
}

void main() {
  final db = DeltaTraceDatabase();
  final now = DateTime.now();
  List<User> users = [
    User(
      id: -1,
      name: 'Taro',
      age: 30,
      createdAt: now,
      updatedAt: now,
      nestedObj: {"a": "a"},
    ),
    User(
      id: -1,
      name: 'Jiro',
      age: 25,
      createdAt: now,
      updatedAt: now,
      nestedObj: {"a": "b"},
    ),
  ];
  // If you want the return value to be reflected immediately on the front end,
  // set returnData = true to get data that properly reflects the serial key.
  final query = QueryBuilder.add(
    target: 'users',
    addData: users,
    serialKey: "id",
    returnData: true,
  ).build();
  // Specifying the "User class" is only necessary if you want to easily revert to the original class.
  final r = db.executeQuery<User>(query);
  // If you want to check the return value, you can easily do so by using toDict, which serializes it.
  print(r.toDict());
  // You can easily convert from the Result object back to the original class.
  // The value of r.result is deserialized using the function specified by convert.
  // List<User> results = r.convert(User.fromDict);
}
