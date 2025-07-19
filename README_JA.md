# delta_trace_db

## 概要
「DeltaTraceDB」は、クラスのリスト単位でデータを格納するインメモリデータベースです。
このデータベースではクラス構造をそのままデータベースに登録でき、登録したクラスの要素を全文検索できます。  
また、クエリもクラスであり、who, when, what, why, fromで構成されるDBの操作情報を持たせられるため、
シリアライズして保存すれば、セキュリティ監査や利用状況の分析において非常にリッチな情報源を提供します。
これは特に医療用などの様々な制約のあるプロジェクトにおいて、威力を発揮します。
また、whenについては、TemporalTraceクラスによる通信経路、 及び各到達時間の完全なトレース機能を持ちます。
これは例えば、光の速度でも無視できない遅延が発生する宇宙規模の通信網や中継サーバーなどで便利ではないかと考えています。

## 速度
本パッケージはインメモリデータベースであるため基本的に高速です。10万レコード程度では通常は問題はありません。  
testフォルダのspeed_test.dartを利用して実際の環境でテストしてみることをおすすめします。  
ただし、データ量の分RAM容量を消費するため、極めて大規模なデータベースが必要な場合は一般的なデータベースの使用を検討してください。
参考までに、少し古めの、Ryzen 3600 CPU搭載PCを使ったスピードテスト(test/speed_test.dart)の実行結果は以下の通りです。
十分に時間がかかる条件をチョイスしてテストしていますが、実用上問題になることは稀だと思います。

```text
speed test for 100000 records
start add
end add: 189 ms
start getAll (with object convert)                                                                                                                                  
end getAll: 302 ms
returnsLength:100000
start save (with json string convert)
end save: 327 ms
start load (with json string convert)
end load: 237 ms
start search (with object convert)
end search: 539 ms
returnsLength:100000
start search paging, half limit pre search (with object convert)
end search paging: 333 ms
returnsLength:50000
start search paging by obj (with object convert)
end search paging by obj: 392 ms
returnsLength:50000
start search paging by offset (with object convert)
end search paging by offset: 403 ms
returnsLength:50000
start update at half index and last index object
end update: 27 ms
start updateOne of half index object
end updateOne: 8 ms
start conformToTemplate
end conformToTemplate: 63 ms
start delete half object (with object convert)
end delete: 267 ms
returnsLength:50000
```

## 使い方
pub.dev の「Examples」タブをご覧ください。  
また、サンプルよりも複雑な例が必要な場合は、test フォルダをご覧ください。

## サポート
基本的にサポートはありませんが、バグは修正される可能性が高いです。
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