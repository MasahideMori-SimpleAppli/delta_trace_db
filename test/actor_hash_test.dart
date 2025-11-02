import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('actor test', () {
    // test a
    final a1 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test"},
    );
    final a2 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add, EnumQueryType.update]),
      },
      context: {"otherData": "test"},
    );
    expect(a1.hashCode != a2.hashCode, true);
    // test b
    final b1 = Actor(
      EnumActorType.human,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test"},
    );
    final b2 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test"},
    );
    expect(b1.hashCode != b2.hashCode, true);
    // test c
    final c1 = Actor(
      EnumActorType.system,
      "2",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test"},
    );
    final c2 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test"},
    );
    expect(c1.hashCode != c2.hashCode, true);
    // test d
    final d1 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test1"},
    );
    final d2 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test2"},
    );
    expect(d1.hashCode != d2.hashCode, true);
    // test e
    final e1 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test"},
    );
    final e2 = Actor(
      EnumActorType.system,
      "1",
      collectionPermissions: {
        "users": Permission([EnumQueryType.add]),
      },
      context: {"otherData": "test"},
    );
    expect(e1.hashCode == e2.hashCode, true);
  });
}
