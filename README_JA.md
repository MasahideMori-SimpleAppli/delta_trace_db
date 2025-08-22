# delta_trace_db

## 概要

「DeltaTraceDB」は、クラスのリスト単位でデータを格納するインメモリデータベース（NoSQL）です。
このデータベースではクラス構造をそのままデータベースに登録でき、登録したクラスの要素を全文検索できます。  
また、クエリもクラスであり、who, when, what, why, fromで構成されるDBの操作情報を持たせられるため、
シリアライズして保存すれば、セキュリティ監査や利用状況の分析において非常にリッチな情報源を提供します。
これは特に医療用などの様々な制約のあるプロジェクトにおいて、威力を発揮します。
また、whenについては、TemporalTraceクラスによる通信経路、 及び各到達時間の完全なトレース機能を持ちます。
これは例えば、光の速度でも無視できない遅延が発生する宇宙規模の通信網や中継サーバーなどで便利ではないかと考えています。

## DBの構造

このDBの構造は、以下のようになっています。  
つまり、各コレクションは各クラスのリストに相当します。  
このため、ユーザーはフロントエンド、バックエンドの差をほとんど意識せず、  
「必要なクラスオブジェクトを取得する」という操作に専念できます。

```
📦 Database (DeltaTraceDB)
├── 🗂️ CollectionA (key: "collection_a")
│   ├── 📄 Item (ClassA)
│   │   ├── id: int
│   │   ├── name: String
│   │   └── timestamp: String
│   └── ...
├── 🗂️ CollectionB (key: "collection_b")
│   ├── 📄 Item (ClassB)
│   │   ├── uid: String
│   │   └── data: Map<String, dynamic>
└── ...
```

## DBの基本操作

このDBの操作は全てがクラスベースです。  
新しくクエリ言語を覚える必要はありません。

### 📦 1. モデルクラスの定義

まず、モデルクラスを用意します。  
モデルクラスにはfile_state_managerパッケージのClonableFileを継承させると便利です。  
ClonableFileを継承したく無い場合はRawQueryBuilderでMap<String,dynamic>を直接扱うこともできます。  
ここではClonableFileを継承させる方法のサンプルを記載します。

```dart
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

  static User fromDict(Map<String, dynamic> src) =>
      User(
        id: src['id'],
        name: src['name'],
        age: src['age'],
        createdAt: DateTime.parse(src['createdAt']),
        updatedAt: DateTime.parse(src['updatedAt']),
        nestedObj: src['nestedObj'],
      );

  @override
  Map<String, dynamic> toDict() =>
      {
        'id': id,
        'name': name,
        'age': age,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'nestedObj': {...nestedObj},
      };

  @override
  User clone() => User.fromDict(toDict());
}
```

### 🏗️ 2. DBを初期化してデータ追加

```dart

final db = DeltaTraceDatabase();
final now = DateTime.now();
final users = [
  User(id: '1',
      name: 'Taro',
      age: 25,
      createdAt: now,
      updatedAt: now,
      nestedObj: {"a": "a"}),
  User(id: '2',
      name: 'Jiro',
      age: 30,
      createdAt: now,
      updatedAt: now,
      nestedObj: {"a": "b"}),
];

final query = QueryBuilder.add(target: 'users', addData: users).build();
// ここの<User>はサーバーでは不要。これはデータ取得時のコンバート処理のための型指定です。
final result = db.executeQuery<User>(query);
```

💡 ポイント

- QueryBuilder で生成したクエリを executeQuery に渡すだけで、データの追加・更新・削除などが行えます。
- このクエリ（query）は toDictメソッドでMap<String, dynamic>
  としてシリアライズ可能なため、必要に応じてそのままサーバーに送信してリモートのデータベースに反映させることができます。
- サーバー側では executeQuery 相当の処理を用意すれば、同じクエリ構造で処理が可能です。
- サーバー側で必要なのはほぼユーザーの権限確認やロギングだけで、ログもクエリをそのまま保存すれば良いので非常に簡単です。
- サーバーからフロントエンドへの結果の返却はexecuteQueryの結果のQueryResultをtoDictして返すだけです。

### 🔍 3. データ検索（フィルタ + ソート + ページング）

```dart

final searchQuery = QueryBuilder.search(
  target: 'users',
  queryNode: FieldContains("name", "ro"), // 名前に「ro」を含む（つまり、TaroとJiroが取得対象）
  sortObj: SingleSort(field: 'age', reversed: true), // 年齢で降順
  limit: 1, // 1件だけ取得
).build();
final searchResult = db.executeQuery<User>(searchQuery);
// Jiroが得られる。
final matchedUsers = searchResult.convert(User.fromDict);

// 次ページのページングを行うクエリ。
final pagingQuery = QueryBuilder.search(
    target: 'users',
    queryNode: FieldContains("name", "ro"),
    // ページングの際、パラメータは以前と同じ設定にする必要があります。
    sortObj: SingleSort(field: 'age', reversed: true),
    limit: 1,
    // 1件だけ取得
    startAfter: searchResult.result.last // ページングを指定。なお、オブジェクトの変わりにオフセットでも指定できます。
).build();
final nextPageSearchResult = db.executeQuery<User>(pagingQuery);
// Taroが得られる。
final nextPageUsers = nextPageSearchResult.convert(User.fromDict);
```

### ✏️ 4. データ更新（複数条件・部分更新）

```dart

final updateQuery = QueryBuilder.update(
  target: 'users',
  queryNode: OrNode([
    FieldEquals('name', 'Taro'),
    FieldEquals('name', 'Jiro'),
  ]),
  overrideData: {'age': 99},
  returnData: true,
).build();

final updateResult = db.executeQuery<User>(updateQuery);
final updated = updateResult.convert(User.fromDict);
```

### ❌ 5. データ削除

```dart

final deleteQuery = QueryBuilder.delete(
  target: 'users',
  queryNode: FieldEquals("name", "Jiro"),
).build();

final deleteResult = db.executeQuery<User>(deleteQuery);
```

### 💾 6. 保存と復元（シリアライズ対応）

```dart
// 保存（Map形式で取得）。この後、お好みで暗号化したり、好きなパッケージを用いて保存してください。
final saved = db.toDict();
// 復元
final loaded = DeltaTraceDatabase.fromDict(saved);
```

🕰️ 変更ログによる完全復元（Queryログ）もできます。
delta_trace_db では、すべての変更操作（add, update, delete等）が Query クラスで表現されます。  
なので、この Query を時系列でログとして保存しておくことで、任意の時点のDB状態を完全に再現できます。

💡 なぜ復元できるのか？

- すべてのデータ操作は Query によって記録される。
- 保存されたクエリログを、初期状態の空DBに 順に再実行すれば同じ状態が得られる。

お勧めは通常の保存を日時スナップショットとし、Queryそのものをログとする構成です。  
こうすると、スナップショット保存時点以降のQueryログを適用するだけで問題発生時点の直前まで復元できますし、
他の全ての操作もログに残っているのでDBの再構築が簡単になります。
クエリにはCauseクラスとして「who, when, what, why, from」で構成されるDBの操作情報を持たせられるため、  
これを適切に設定すれば、問題を更に特定しやすくなります。

### 🧠 7. ネストされたフィールドでの検索や、その他のNodeを使った検索について

ネストされたフィールドについては、「nestedObj.a」のように「.」区切りでキーを指定できます。  
検索で利用できるノードについては、「LogicalNode（AndやOr）」と「ComparisonNode（Equalsなど）」があります。  
利用可能な種類については以下を確認してください。  
[logicalNode](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/lib/src/query/nodes/logical_node.dart)  
[comparisonNode](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/lib/src/query/nodes/comparison_node.dart)

### 🧬 8. 型変換・テンプレート変換（conformToTemplate）

保存されたデータを新しい構造に変換したいときに便利なのが conformToTemplate 機能です。  
この機能は、保存データに欠損があってもテンプレートに沿って補完・変換することができます。

```dart
// 元のクラス
class ClassA extends ClonableFile {
  String id;
  String name;

  ClassB(this.id, this.name)
// 以下省略
}

final db = DeltaTraceDatabase();
final users = [
  ClassA(id: 'u003', name: 'Hanako')
];
final query = QueryBuilder.add(target: 'users', addData: users).build();
final result = db.executeQuery<User>(query);

// ClassAから変更したい新しいクラス
class ClassB extends ClonableFile {
  String id;
  String name;
  int age;

  ClassB(this.id, this.name, this.age)
// 以下省略
}

final Query conformQuery = QueryBuilder.conformToTemplate(
  target: 'users',
  template: ClassB(id: '', name: '', age: -1), // 未定義のageは初期値の-1で補完される
).build();
final QueryResult<ClassB> _ = db.executeQuery<ClassB>(conformQuery);

// => { 'id': 'u003', 'name': 'Hanako', 'age': -1 }
final conformedUser = ClassB.fromDict(db
    .collection("users")
    .raw[0]);
```

### 🔁 9. トランザクション処理

複数のクエリを１つの処理として扱いたい場合にはトランザクションクエリが利用できます。  
このクエリで処理を行った場合、戻り値のisSuccessがfalseになる条件では、  
DBがトランザクションクエリ実行前の状態に巻き戻されます。  
内部的には更新対象のコレクションが一時的にメモリ上にバッファされるので、  
その分のメモリを追加で確保しておく必要があることに注意してください。  

```dart
    final now = DateTime.now();
    final db = DeltaTraceDatabase();
    List<User> users = [
      User(
        id: '1',
        name: 'Taro',
        age: 25,
        createdAt: now.add(Duration(days: 0)),
        updatedAt: now.add(Duration(days: 0)),
        nestedObj: {},
      ),
      User(
        id: '2',
        name: 'Jiro',
        age: 28,
        createdAt: now.add(Duration(days: 1)),
        updatedAt: now.add(Duration(days: 1)),
        nestedObj: {},
      ),
      User(
        id: '3',
        name: 'Saburo',
        age: 31,
        createdAt: now.add(Duration(days: 2)),
        updatedAt: now.add(Duration(days: 2)),
        nestedObj: {},
      ),
      User(
        id: '4',
        name: 'Hanako',
        age: 17,
        createdAt: now.add(Duration(days: 3)),
        updatedAt: now.add(Duration(days: 3)),
        nestedObj: {},
      ),
    ];
    // 追加
    final Query q1 = QueryBuilder.add(target: 'users1', addData: users).build();
    final Query q2 = QueryBuilder.add(target: 'users2', addData: users).build();
    QueryResult<User> _ = db.executeQuery<User>(q1);
    QueryResult<User> _ = db.executeQuery<User>(q2);
    // 失敗するトランザクション
    final TransactionQuery tq1 = TransactionQuery(
      queries: [
        QueryBuilder.update(
          target: 'users1',
          // 型が違う
          queryNode: FieldEquals("id", 3),
          overrideData: {"id": 5},
          returnData: true,
          mustAffectAtLeastOne: true,
        ).build(),
        QueryBuilder.clear(target: 'users2').build(),
      ],
    );
    // result.isSuccess は falseで失敗になります。 DBは変更されません。
    // 巻き戻しは、DB 内のすべてのコレクション (この場合は、users1 と users2) に適用されます。
    QueryExecutionResult result = db.executeQueryObject(tq1);
    // 成功するトランザクション
    final TransactionQuery tq2 = TransactionQuery(
      queries: [
        QueryBuilder.update(
          target: 'users1',
          queryNode: FieldEquals("id", "3"),
          // オーバーライドする型にも注意してください。このライブラリでは、他の型によるオーバーライドが可能です。
          overrideData: {"id": "5"},
          returnData: true,
          mustAffectAtLeastOne: true,
        ).build(),
        QueryBuilder.clear(target: 'users2').build(),
      ],
    );
    QueryExecutionResult result2 = db.executeQueryObject(tq2);
```

## 速度

本パッケージはインメモリデータベースであるため基本的に高速です。
現在、特に高速化のための仕組みを備えていませんが、プログラムのforループとほぼ同等の動きをするため、
10万レコード程度では通常は問題はありません。  
testフォルダのspeed_test.dartを利用して実際の環境でテストしてみることをおすすめします。  
ただし、データ量の分RAM容量を消費するため、極めて大規模なデータベースが必要な場合は一般的なデータベースの使用を検討してください。
参考までに、少し古めの、Ryzen 3600 CPU搭載PCを使ったスピードテスト(test/speed_test.dart)の実行結果は以下の通りです。
十分に時間がかかる条件をチョイスしてテストしていますが、実用上問題になることは稀だと思います。

```text
speed test for 100000 records
start add
end add: 176 ms
start getAll (with object convert)
end getAll: 270 ms
returnsLength:100000
start save (with json string convert)
end save: 326 ms
start load (with json string convert)
end load: 239 ms
start search (with object convert)
end search: 429 ms
returnsLength:100000
start search paging, half limit pre search (with object convert)
end search paging: 346 ms
returnsLength:50000
start search paging by obj (with object convert)
end search paging by obj: 340 ms
returnsLength:50000
start search paging by offset (with object convert)
end search paging by offset: 322 ms
returnsLength:50000
start update at half index and last index object
end update: 55 ms
start updateOne of half index object
end updateOne: 12 ms
start conformToTemplate
end conformToTemplate: 69 ms
start delete half object (with object convert)
end delete: 205 ms
returnsLength:50000
start deleteOne for last object (with object convert)
end deleteOne: 7 ms
returnsLength:1
```

## 今後の予定について

DBの高速化は可能ですが優先度はかなり低いので、使い勝手の改善や周辺ツールの作成などが優先されると思います。

## サポート

現時点では基本的にサポートはありませんが、バグは修正される可能性が高いです。  
もし問題を見つけた場合はGithubのissueを開いてください。

## バージョン管理について

それぞれ、Cの部分が変更されます。  
ただし、バージョン1.0.0未満は以下のルールに関係無くファイル構造が変化する場合があります。

- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更
    - C.X.X
- メソッドの追加など
    - X.C.X
- 軽微な変更やバグ修正
    - X.X.C

## ライセンス

このソフトウェアはApache-2.0ライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

Copyright 2025 Masahide Mori

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## 著作権表示

The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.