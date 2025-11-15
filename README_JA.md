# delta_trace_db

## 概要

**DeltaTraceDB は、クラス構造をそのまま保存・検索できる軽量・高速のインメモリ NoSQL データベースです。**  
NoSQLですが、ネストされた子クラスの値についても全文検索が行えます。

さらに、DeltaTraceDB のクエリはクラスであり、  
クエリ自体をシリアライズして保存することで任意の時点のDBを復元できる他、  
**who / when / what / why / from** 等の操作情報を保持可能です。  
これにより、セキュリティ監査や利用状況分析に利用できる「リッチな操作ログ」を作ることができます。

## 特徴
- **クラスをそのまま保存・検索**（モデルクラス＝DB構造）
- Dart / Flutter で動作する軽量インメモリ DB
- 約 10 万件レベルでも高速な検索性能
- クエリ自体がクラスなので操作ログとして保存可能
- Python 版あり  
  → https://pypi.org/project/delta-trace-db/
- DB の内容を編集できる GUI ツールも開発中  
  → https://github.com/MasahideMori-SimpleAppli/delta_trace_studio

## クイックスタート

```dart
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
  List<User> results = r.convert(User.fromDict);
}
```

## DB の構造

DeltaTraceDB では、各コレクションが「クラスのリスト」に相当します。  
クラス設計そのままでデータが扱えるため、フロントエンド・バックエンド間の整合性がとりやすく、  
「必要なクラスオブジェクトを取得する」という自然な操作に集中できます。

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

## 基本操作

詳細な使用方法やクエリの記述などは、オンラインドキュメントをご覧ください。

📘 [オンラインドキュメント](https://masahidemori-simpleappli.github.io/delta_trace_db_docs/)

## パフォーマンス

本パッケージはインメモリ DB のため基本的に高速です。  
プログラムの for ループに近い性能で動作するため、10 万件規模では実用上ほぼ問題ありません。  

テストコードは以下にあります。
```
test/speed_test.dart
```

また、以下は Ryzen 3600 の PC で実施した実際の結果です。
```text
speed test for 100000 records                                                                                                                                                                                                                                                       
start add
end add: 178 ms
start getAll (with object convert)
end getAll: 638 ms
returnsLength:100000
start save (with json string convert)
end save: 354 ms
start load (with json string convert)
end load: 259 ms
start search (with object convert)
end search: 780 ms
returnsLength:100000
start search paging, half limit pre search (with object convert)
end search paging: 440 ms
returnsLength:50000
start search paging by obj (with object convert)
end search paging by obj: 543 ms
returnsLength:50000
start search paging by offset (with object convert)
end search paging by offset: 438 ms
returnsLength:50000
start searchOne, the last index object search (with object convert)
end searchOne: 19 ms
returnsLength:1
start update at half index and last index object
end update: 22 ms
start updateOne of half index object
end updateOne: 6 ms
start conformToTemplate
end conformToTemplate: 65 ms
start delete half object (with object convert)
end delete: 450 ms
returnsLength:50000
start deleteOne for last object (with object convert)
end deleteOne: 6 ms
returnsLength:1
start add with serialKey
end add with serialKey: 54 ms
addedCount:100000
```

## 今後の予定について

高速化は可能なものの優先度は低めで、  
使い勝手の向上や周辺ツールの開発 が主な改良対象になる予定です。

## 注意事項

本パッケージは **シングルスレッド前提** で設計されています。  
メモリを共有しない並列処理では、メッセージパッシングなどの追加処理が必要なことに注意してください。

## サポート

公式サポートはありませんが、バグは積極的に修正される可能性があります。  
問題を見つけた場合は GitHub Issue へお願いします。

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

## Trademarks

- “Dart” and “Flutter” are trademarks of Google LLC.  
  *This package is not developed or endorsed by Google LLC.*

- “Python” is a trademark of the Python Software Foundation.  
  *This package is not affiliated with the Python Software Foundation.*

- GitHub and the GitHub logo are trademarks of GitHub, Inc.  
  *This package is not affiliated with GitHub, Inc.*