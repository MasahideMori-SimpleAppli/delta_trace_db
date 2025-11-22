import 'package:test/test.dart';
import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:collection/collection.dart';

void main() {
  group('Actor', () {
    test('Constructor sets createdAt and updatedAt', () {
      final before = DateTime.now().toUtc();
      final actor = Actor(EnumActorType.human, 'user1');
      final after = DateTime.now().toUtc();

      expect(actor.createdAt, isNotNull);
      expect(actor.updatedAt, isNotNull);
      expect(
        actor.createdAt!.isAfter(before) ||
            actor.createdAt!.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        actor.createdAt!.isBefore(after) ||
            actor.createdAt!.isAtSameMomentAs(after),
        isTrue,
      );
      expect(actor.updatedAt == actor.createdAt, isTrue);
    });

    test('updateAccess initializes lastAccessDay and operationInDay', () {
      final actor = Actor(EnumActorType.human, 'user1');
      expect(actor.lastAccessDay, isNull);
      expect(actor.operationInDay, isNull);

      actor.updateAccess(DateTime.utc(2025, 11, 22, 12), resetHour: 5);

      expect(actor.lastAccess, isNotNull);
      expect(actor.lastAccessDay, isNotNull);
      expect(actor.operationInDay == 1, isTrue);
    });

    test('updateAccess increments operationInDay on same reset day', () {
      final actor = Actor(EnumActorType.human, 'user1');
      final now = DateTime.utc(2025, 11, 22, 12);
      actor.updateAccess(now, resetHour: 5);
      actor.updateAccess(now.add(const Duration(hours: 1)), resetHour: 5);

      expect(actor.operationInDay == 2, isTrue);
    });

    test('updateAccess resets operationInDay on new reset day', () {
      final actor = Actor(EnumActorType.human, 'user1');
      final now = DateTime.utc(2025, 11, 22, 12);
      actor.updateAccess(now, resetHour: 5);

      final nextDay = now.add(const Duration(days: 1, hours: 1));
      actor.updateAccess(nextDay, resetHour: 5);

      expect(actor.operationInDay == 1, isTrue);
      expect(actor.lastAccessDay!.day == nextDay.day, isTrue);
    });

    test('toDict and fromDict roundtrip', () {
      final actor = Actor(
        EnumActorType.ai,
        'ai1',
        name: 'AI Bot',
        email: 'ai@example.com',
        deviceIds: ['device1', 'device2'],
      );

      final dict = actor.toDict();
      final restored = Actor.fromDict(dict);

      expect(restored == actor, isTrue);
      expect(
        ListEquality().equals(restored.deviceIds, actor.deviceIds),
        isTrue,
      );
    });

    test('Equality and hashCode', () {
      final actor1 = Actor(EnumActorType.human, 'user1', name: 'User');
      final actor2 = Actor(EnumActorType.human, 'user1', name: 'User');

      expect(actor1 == actor2, isTrue);
      expect(actor1.hashCode == actor2.hashCode, isTrue);

      final actor3 = Actor(EnumActorType.human, 'user2', name: 'User');
      expect(actor1 != actor3, isTrue);
    });

    test('DeviceIds equality', () {
      final actor1 = Actor(
        EnumActorType.human,
        'user1',
        deviceIds: ['d1', 'd2'],
      );
      final actor2 = Actor(
        EnumActorType.human,
        'user1',
        deviceIds: ['d1', 'd2'],
      );
      final actor3 = Actor(
        EnumActorType.human,
        'user1',
        deviceIds: ['d2', 'd1'],
      );

      expect(actor1 == actor2, isTrue);
      expect(actor1 != actor3, isTrue);
    });

    // --------------------------
    // 異常系 / エッジケース
    // --------------------------
    test('updateAccess throws on invalid resetHour', () {
      final actor = Actor(EnumActorType.human, 'user1');
      expect(
        () => actor.updateAccess(DateTime.now(), resetHour: -1),
        throwsArgumentError,
      );
      expect(
        () => actor.updateAccess(DateTime.now(), resetHour: 24),
        throwsArgumentError,
      );
    });

    test('updateAccess works with UTC and non-UTC DateTime', () {
      final actor1 = Actor(EnumActorType.human, 'user1');
      final localNow = DateTime(2025, 11, 22, 12); // local time
      actor1.updateAccess(localNow, resetHour: 5);

      final actor2 = Actor(EnumActorType.human, 'user2');
      final utcNow = localNow.toUtc();
      actor2.updateAccess(utcNow, resetHour: 5);

      expect(actor1.lastAccess!.toUtc() == actor2.lastAccess!.toUtc(), isTrue);
    });

    test('fromDict handles missing optional fields', () {
      final map = {'type': 'human', 'id': 'user1'};
      final actor = Actor.fromDict(map);

      expect(actor.name, isNull);
      expect(actor.email, isNull);
      expect(actor.collectionPermissions, isNull);
      expect(actor.deviceIds, isNull);
    });

    test('fromDict handles null lists and maps', () {
      final map = {
        'type': 'human',
        'id': 'user1',
        'deviceIds': null,
        'collectionPermissions': null,
        'context': null,
      };
      final actor = Actor.fromDict(map);

      expect(actor.deviceIds, isNull);
      expect(actor.collectionPermissions, isNull);
      expect(actor.context, isNull);
    });

    test('updateAccess handles null lastAccessDay initially', () {
      final actor = Actor(EnumActorType.human, 'user1');
      expect(actor.lastAccessDay, isNull);

      actor.updateAccess(DateTime.utc(2025, 11, 22, 6), resetHour: 5);

      expect(actor.lastAccessDay, isNotNull);
      expect(actor.operationInDay == 1, isTrue);
    });

    test('updateAccess handles multiple consecutive days', () {
      final actor = Actor(EnumActorType.human, 'user1');
      final day1 = DateTime.utc(2025, 11, 22, 6);
      actor.updateAccess(day1, resetHour: 5);

      final day2 = DateTime.utc(2025, 11, 23, 6);
      actor.updateAccess(day2, resetHour: 5);

      final day3 = DateTime.utc(
        2025,
        11,
        24,
        4,
      ); // before resetHour, should still count as day2
      actor.updateAccess(day3, resetHour: 5);

      expect(actor.operationInDay == 2, isTrue);
      expect(actor.lastAccessDay!.day == 23, isTrue);
    });
  });

  // --------------------------
  // 長期間系のテスト。
  // --------------------------
  test('updateAccess large scale simulation', () {
    final actor = Actor(EnumActorType.human, 'user1');
    DateTime now = DateTime.utc(2025, 1, 1, 0);
    final resetHour = 5;

    for (int day = 0; day < 30; day++) {
      // 1ヶ月分で簡易テスト
      for (int hour = 0; hour < 24; hour++) {
        final accessTime = now.add(Duration(days: day, hours: hour));
        actor.updateAccess(accessTime, resetHour: resetHour);

        // operationInDay は 1以上
        expect(actor.operationInDay! >= 1, isTrue);
        // lastAccessDay は UTC resetHour
        expect(actor.lastAccessDay!.hour == resetHour, isTrue);
      }
    }
  });
}
