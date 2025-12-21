import 'package:test/test.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

void main() {
  group('MergeQuery Test', () {
    test('merge query', () {
      final baseCollection = <Map<String, dynamic>>[
        {"id": -1, "name": "Alice", "groupId": "g1", "age": 30},
        {"id": -1, "name": "Bob", "groupId": "g2", "age": 25},
      ];
      final sourceUserDetail = <Map<String, dynamic>>[
        {
          "userId": 0,
          "email": "alice@example.com",
          "address": {"city": "Tokyo", "zip": "100-0001"},
        },
        {
          "userId": 1,
          "email": "bob@example.com",
          "address": {"city": "Osaka", "zip": "530-0001"},
        },
      ];
      final sourceUserStatus = <Map<String, dynamic>>[
        {
          "uid": 0,
          "status": "active",
          "flags": {"admin": true, "beta": false},
        },
        // id=1 は存在しない（未マッチテスト用）
      ];
      final params = MergeQueryParams(
        base: "baseUsers",
        source: ["userDetail", "userStatus"],
        relationKey: "id",
        sourceKeys: [
          "userId", // source[0]
          "uid", // source[1]
        ],
        output: "mergedUsers",
        dslTmp: {
          "id": "base.id",
          "name": "base.name",
          "age": "base.age",
          // source[0]
          "email": "0.email",
          "city": "0.address.city",
          // source[1]（無い場合は null）
          "status": "1.status",
          // popped テスト
          "publicProfile": "popped.base[groupId,age]",
          // array wrap
          "emails": "[0.email]",
          // literal
          "active": "bool(true)",
          "score": "int(100)",
        },
        serialBase: "baseUsers",
      );
      // db creation.
      final db = DeltaTraceDatabase();
      db.executeQuery(
        RawQueryBuilder.add(
          target: "baseUsers",
          rawAddData: baseCollection,
          serialKey: "id",
          returnData: true,
        ).build(),
      );

      db.executeQuery(
        RawQueryBuilder.add(
          target: "userDetail",
          rawAddData: sourceUserDetail,
        ).build(),
      );
      db.executeQuery(
        RawQueryBuilder.add(
          target: "userStatus",
          rawAddData: sourceUserStatus,
        ).build(),
      );
      // execute merge query.
      final r = db.executeQuery(
        QueryBuilder.merge(mergeQueryParams: params).build(),
      );
      final Collection? mergeResult = db.findCollection("mergedUsers");
      // test
      expect(mergeResult, isNotNull);
      final List<Map<String, dynamic>> items = mergeResult!.raw;
      expect(items.length, 2);

      // Alice
      final alice = items.firstWhere((e) => e["id"] == 0);
      expect(alice["name"], "Alice");
      expect(alice["email"], "alice@example.com");
      expect(alice["status"], "active");
      expect(alice["publicProfile"], {"id": 0, "name": "Alice"});

      // Bob
      final bob = items.firstWhere((e) => e["id"] == 1);
      expect(bob["name"], "Bob");
      expect(bob["email"], "bob@example.com");
      expect(bob["status"], isNull);
      expect(bob["publicProfile"], {"id": 1, "name": "Bob"});

      // 元データを破壊していないことを検証
      expect(baseCollection[0].containsKey("groupId"), isTrue);

      //シリアルナンバーが引き継げているかを確認。
      expect(mergeResult.getSerialNum() == 2, true);
    });

    test('merge query new serial key', () {
      final baseCollection = <Map<String, dynamic>>[
        {"id": 1, "name": "Alice", "groupId": "g1", "age": 30},
        {"id": 2, "name": "Bob", "groupId": "g2", "age": 25},
      ];
      final sourceUserDetail = <Map<String, dynamic>>[
        {
          "userId": 1,
          "email": "alice@example.com",
          "address": {"city": "Tokyo", "zip": "100-0001"},
        },
        {
          "userId": 2,
          "email": "bob@example.com",
          "address": {"city": "Osaka", "zip": "530-0001"},
        },
      ];
      final sourceUserStatus = <Map<String, dynamic>>[
        {
          "uid": 1,
          "status": "active",
          "flags": {"admin": true, "beta": false},
        },
        // id=2 は存在しない（未マッチテスト用）
      ];
      final params = MergeQueryParams(
        base: "baseUsers",
        source: ["userDetail", "userStatus"],
        relationKey: "id",
        sourceKeys: [
          "userId", // source[0]
          "uid", // source[1]
        ],
        output: "mergedUsers",
        dslTmp: {
          "id": "base.id",
          "name": "base.name",
          "age": "base.age",
          // source[0]
          "email": "0.email",
          "city": "0.address.city",
          // source[1]（無い場合は null）
          "status": "1.status",
          // popped テスト
          "publicProfile": "popped.base[groupId,age]",
          // array wrap
          "emails": "[0.email]",
          // literal
          "active": "bool(true)",
          "score": "int(100)",
        },
        serialKey: "id",
      );
      // db creation.
      final db = DeltaTraceDatabase();
      db.executeQuery(
        RawQueryBuilder.add(
          target: "baseUsers",
          rawAddData: baseCollection,
        ).build(),
      );
      db.executeQuery(
        RawQueryBuilder.add(
          target: "userDetail",
          rawAddData: sourceUserDetail,
        ).build(),
      );
      db.executeQuery(
        RawQueryBuilder.add(
          target: "userStatus",
          rawAddData: sourceUserStatus,
        ).build(),
      );
      // execute merge query.
      final r = db.executeQuery(
        QueryBuilder.merge(mergeQueryParams: params).build(),
      );
      final Collection? mergeResult = db.findCollection("mergedUsers");
      // test
      expect(mergeResult, isNotNull);
      final List<Map<String, dynamic>> items = mergeResult!.raw;
      expect(items.length, 2);

      // ここでは、idがシリアルとして新規に振られるため、0始まりに切り替わる。
      // ただし、"publicProfile"には変更前のidが入るので、1や2の値が入る。
      // Alice
      final alice = items.firstWhere((e) => e["id"] == 0);
      expect(alice["name"], "Alice");
      expect(alice["email"], "alice@example.com");
      expect(alice["status"], "active");
      expect(alice["publicProfile"], {"id": 1, "name": "Alice"});

      // Bob
      final bob = items.firstWhere((e) => e["id"] == 1);
      expect(bob["name"], "Bob");
      expect(bob["email"], "bob@example.com");
      expect(bob["status"], isNull);
      expect(bob["publicProfile"], {"id": 2, "name": "Bob"});

      // 元データを破壊していないことを検証
      expect(baseCollection[0].containsKey("groupId"), isTrue);

      //シリアルナンバーが新規作成後にインクリメントされているかを確認。
      expect(mergeResult.getSerialNum() == 2, true);
    });
  });

  group('MergeQuery broken DSL patterns', () {
    final baseCollection = <Map<String, dynamic>>[
      {"id": -1, "name": "Alice", "groupId": "g1", "age": 30},
      {"id": -1, "name": "Bob", "groupId": "g2", "age": 25},
    ];
    final sourceUserDetail = <Map<String, dynamic>>[
      {"userId": 0, "email": "alice@example.com"},
      {"userId": 1, "email": "bob@example.com"},
    ];
    final brokenDslPatterns = <String>[
      "",
      "base.",
      "int(",
      "bool(TRUE)",
      "popped.base[a,b",
      "2.email",
    ];
    for (final brokenDsl in brokenDslPatterns) {
      test('merge query broken DSL: "$brokenDsl"', () {
        final params = MergeQueryParams(
          base: "baseUsers",
          source: ["userDetail"],
          relationKey: "id",
          sourceKeys: ["userId"],
          output: "mergedUsers",
          dslTmp: {"id": brokenDsl},
        );
        final db = DeltaTraceDatabase();
        db.executeQuery(
          RawQueryBuilder.add(
            target: "baseUsers",
            rawAddData: baseCollection,
            serialKey: "id",
          ).build(),
        );
        db.executeQuery(
          RawQueryBuilder.add(
            target: "userDetail",
            rawAddData: sourceUserDetail,
          ).build(),
        );
        final result = db.executeQuery(
          QueryBuilder.merge(mergeQueryParams: params).build(),
        );
        expect(result.isSuccess, isFalse);
      });
    }
  });

  test('merge query nestedKey', () {
    final baseCollection = <Map<String, dynamic>>[
      {
        "t": {"id": 0},
        "name": "Alice",
        "groupId": "g1",
        "age": 30,
      },
      {
        "t": {"id": 1},
        "name": "Bob",
        "groupId": "g2",
        "age": 25,
      },
    ];
    final sourceUserDetail = <Map<String, dynamic>>[
      {
        "test": {"userId": 0},
        "email": "alice@example.com",
        "address": {"city": "Tokyo", "zip": "100-0001"},
      },
      {
        "test": {"userId": 1},
        "email": "bob@example.com",
        "address": {"city": "Osaka", "zip": "530-0001"},
      },
    ];
    final sourceUserStatus = <Map<String, dynamic>>[
      {
        "uid": 0,
        "status": "active",
        "flags": {"admin": true, "beta": false},
      },
      // id=1 は存在しない（未マッチテスト用）
    ];
    final params = MergeQueryParams(
      base: "baseUsers",
      source: ["userDetail", "userStatus"],
      relationKey: "t.id",
      sourceKeys: [
        "test.userId", // source[0]
        "uid", // source[1]
      ],
      output: "mergedUsers",
      dslTmp: {
        "id": "base.t.id",
        "name": "base.name",
        "age": "base.age",
        // source[0]
        "email": "0.email",
        "city": "0.address.city",
        // source[1]（無い場合は null）
        "status": "1.status",
        // popped テスト
        "publicProfile": "popped.base[groupId,age]",
        // array wrap
        "emails": "[0.email]",
        // literal
        "active": "bool(true)",
        "score": "int(100)",
      },
    );
    // db creation.
    final db = DeltaTraceDatabase();
    db.executeQuery(
      RawQueryBuilder.add(
        target: "baseUsers",
        rawAddData: baseCollection,
      ).build(),
    );

    db.executeQuery(
      RawQueryBuilder.add(
        target: "userDetail",
        rawAddData: sourceUserDetail,
      ).build(),
    );
    db.executeQuery(
      RawQueryBuilder.add(
        target: "userStatus",
        rawAddData: sourceUserStatus,
      ).build(),
    );
    // execute merge query.
    final r = db.executeQuery(
      QueryBuilder.merge(mergeQueryParams: params).build(),
    );
    final Collection? mergeResult = db.findCollection("mergedUsers");
    // test
    expect(mergeResult, isNotNull);
    final List<Map<String, dynamic>> items = mergeResult!.raw;
    expect(items.length, 2);

    // Alice
    final alice = items.firstWhere((e) => e["id"] == 0);
    expect(alice["name"], "Alice");
    expect(alice["email"], "alice@example.com");
    expect(alice["status"], "active");
    expect(alice["publicProfile"], {
      "t": {"id": 0},
      "name": "Alice",
    });

    // Bob
    final bob = items.firstWhere((e) => e["id"] == 1);
    expect(bob["name"], "Bob");
    expect(bob["email"], "bob@example.com");
    expect(bob["status"], isNull);
    expect(bob["publicProfile"], {
      "t": {"id": 1},
      "name": "Bob",
    });

    // 元データを破壊していないことを検証
    expect(baseCollection[0].containsKey("groupId"), isTrue);
  });
}
