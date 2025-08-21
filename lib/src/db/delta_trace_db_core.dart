import 'package:file_state_manager/file_state_manager.dart';
import '../../delta_trace_db.dart';

/// (en) It is an in-memory database that takes into consideration the
/// safety of various operations.
/// It was created with the assumption that in addition to humans,
/// AI will also be the main users.
///
/// (ja) 様々な操作の安全性を考慮したインメモリデータベースです。
/// 人間以外で、AIも主な利用者であると想定して作成しています。
class DeltaTraceDatabase extends CloneableFile {
  static const String className = "DeltaTraceDatabase";
  static const String version = "6";

  late final Map<String, Collection> _collections;

  /// (en) Create a regular empty database.
  ///
  /// (ja) 通常の空データベースを作成します。
  DeltaTraceDatabase() : _collections = {};

  /// (en) Restore the database from JSON.
  /// Note that src is used as is, not copied.
  ///
  /// (ja) データベースをJSONから復元します。
  /// srcはコピーされずにそのまま利用されることに注意してください。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  DeltaTraceDatabase.fromDict(Map<String, dynamic> src)
    : _collections = _parseCollections(src);

  /// データベースのJSONからの復元処理。
  static Map<String, Collection> _parseCollections(Map<String, dynamic> src) {
    final raw = src["collections"];
    if (raw is! Map<String, dynamic>) {
      throw FormatException(
        "Invalid format: 'collections' should be a Map<String, dynamic>.",
      );
    }
    final Map<String, Collection> r = {};
    for (final entry in raw.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        throw FormatException(
          "Invalid format: value of collection '$key' is not a Map.",
        );
      }
      // ここでもエラーが起きれば、そのままエラーとしてスローされて良い。
      r[key] = Collection.fromDict(value);
    }
    return r;
  }

  /// (en) If the specified collection exists, it will be retrieved.
  /// If it does not exist, a new one will be created and retrieved.
  /// Normally you should not call this directly, but rather operate via queries.
  ///
  /// (ja) 指定のコレクションが存在すればそれを取得し、
  /// 存在しなければ新しく作成して取得します。
  /// 通常は直接これを呼び出さず、クエリ経由で操作してください。
  ///
  /// * [name] : The collection name.
  Collection collection(String name) {
    if (_collections.containsKey(name)) {
      return _collections[name] as Collection;
    }
    final col = Collection();
    _collections[name] = col;
    return col;
  }

  /// (en) Saves individual collections as dictionaries.
  /// For example, you can use this if you want to store a specific collection
  /// in an encrypted format.
  ///
  /// (ja) 個別のコレクションを辞書として保存します。
  /// 特定のコレクション単位で暗号化して保存したいような場合に利用できます。
  ///
  /// * [name] : The collection name.
  Map<String, dynamic> collectionToDict(String name) =>
      _collections[name]?.toDict() ?? {};

  /// (en) Restores a specific collection from a dictionary, re-registers it,
  /// and retrieves it.
  /// If a collection with the same name already exists, it will be overwritten.
  /// This is typically used to restore data saved with collectionToDict.
  ///
  ///
  /// (ja) 特定のコレクションを辞書から復元して再登録し、取得します。
  /// 既存の同名のコレクションが既にある場合は上書きされます。
  /// 通常は、collectionToDictで保存したデータを復元する際に使用します。
  ///
  /// * [name] : The collection name.
  /// * [src] : A dictionary made with collectionToDict of this class.
  Collection collectionFromDict(String name, Map<String, dynamic> src) {
    final col = Collection.fromDict(src);
    _collections[name] = col;
    return col;
  }

  /// (en) Restores a specific collection from a dictionary, re-registers it,
  /// and retrieves it.
  /// If a collection with the same name already exists, it will be overwritten.
  /// This is typically used to restore data saved with collectionToDict.
  /// This method preserves existing listeners when overwriting the specified
  /// collection.
  ///
  /// (ja) 特定のコレクションを辞書から復元して再登録し、取得します。
  /// 既存の同名のコレクションが既にある場合は上書きされます。
  /// 通常は、collectionToDictで保存したデータを復元する際に使用します。
  /// このメソッドでは、指定されたコレクションの上書き時、既存のリスナが維持されます。
  ///
  /// * [name] : The collection name.
  /// * [src] : A dictionary made with collectionToDict of this class.
  Collection collectionFromDictKeepListener(
    String name,
    Map<String, dynamic> src,
  ) {
    final col = Collection.fromDict(src);
    Set<void Function()>? listenersBuf = _collections[name]?.listeners;
    _collections[name] = col;
    if (listenersBuf != null) {
      _collections[name]!.listeners = listenersBuf;
    }
    return col;
  }

  @override
  DeltaTraceDatabase clone() {
    return DeltaTraceDatabase.fromDict(toDict());
  }

  /// (en) Returns the stored contents as a reference.
  /// Be careful as it is dangerous to edit it directly.
  ///
  /// (ja) 保持している内容を参照として返します。
  /// 直接編集すると危険なため注意してください。
  Map<String, Collection> get raw => _collections;

  @override
  Map<String, dynamic> toDict() {
    final Map<String, Map<String, dynamic>> mCollections = {};
    for (String k in _collections.keys) {
      mCollections[k] = _collections[k]!.toDict();
    }
    return {
      "className": className,
      "version": version,
      "collections": mCollections,
    };
  }

  /// (en) This is a callback setting function that can be used when linking
  /// the UI and DB.
  /// The callback set here will be called when the contents of the [target]
  /// collection are changed.
  /// In other words, if you register it, you will be able to update the screen,
  /// etc. when the contents of the DB change.
  /// Normally you would register it in initState and then use removeListener
  /// to remove it when disposing.
  /// If you use this on the server side, it may be a good idea to set up a
  /// function that writes the backup to storage.
  /// Please note that notifications will not be restored even if the DB is
  /// deserialized. You will need to set them every time.
  ///
  /// (ja) UIとDBを連携する際に利用できる、コールバックの設定関数です。
  /// ここで設定したコールバックは、[target]のコレクションの内容が変更されると呼び出されます。
  /// つまり、登録しておくとDBの内容変更時に画面更新等ができるようになります。
  /// 通常はinitStateで登録し、dispose時にremoveListenerを使って解除してください。
  /// これをサーバー側で使用する場合は、バックアップをストレージに書き込む関数などを設定
  /// するのも良いかもしれません。
  /// なお、通知に関してはDBをデシリアライズしても復元されません。毎回設定する必要があります。
  ///
  /// * [target] : The target collection name.
  /// * [cb] : The function to execute when the DB is changed.
  void addListener(String target, void Function() cb) {
    Collection col = collection(target);
    col.addListener(cb);
  }

  /// (en) This function is used to cancel the set callback.
  /// Call it in the UI using dispose etc.
  ///
  /// (ja) 設定したコールバックを解除するための関数です。
  /// UIではdisposeなどで呼び出します。
  ///
  /// * [target] : The target collection name.
  /// * [cb] : The function for which you want to cancel the notification.
  void removeListener(String target, void Function() cb) {
    Collection col = collection(target);
    col.removeListener(cb);
  }

  /// (en) Executes a query of any type.
  /// This function can execute a regular query, a transactional query,
  /// or a Map of any of these.
  /// Server side, verify that the call is legitimate
  /// (e.g. by checking the JWT and/or the caller's user permissions)
  /// before making this call.
  ///
  /// (ja) 型を問わずにクエリを実行します。
  /// この関数は、通常のクエリ、トランザクションクエリ、
  /// またはそれらをMapにしたもののいずれでも実行できます。
  /// サーバーサイドでは、この呼び出しの前に正規の呼び出しであるかどうかの
  /// 検証(JWTのチェックや呼び出し元ユーザーの権限のチェック)を行ってください。
  QueryExecutionResult executeQueryObject(Object query) {
    if (query is Query) {
      return executeQuery(query);
    } else if (query is TransactionQuery) {
      return executeTransactionQuery(query);
    } else if (query is Map<String, dynamic>) {
      if (query["className"] == "Query") {
        return executeQuery(Query.fromDict(query));
      } else if (query["className"] == "TransactionQuery") {
        return executeTransactionQuery(TransactionQuery.fromDict(query));
      } else {
        throw ArgumentError("Unsupported query class: ${query["className"]}");
      }
    } else {
      throw ArgumentError("Unsupported query type: ${query.runtimeType}");
    }
  }

  /// (en) Execute the query.
  /// Server side, verify that the call is legitimate
  /// (e.g. by checking the JWT and/or the caller's user permissions)
  /// before making this call.
  ///
  /// (ja) クエリを実行します。
  /// サーバーサイドでは、この呼び出しの前に正規の呼び出しであるかどうかの
  /// 検証(JWTのチェックや呼び出し元ユーザーの権限のチェック)を行ってください。
  QueryResult<T> executeQuery<T>(Query q) {
    Collection col = collection(q.target);
    try {
      QueryResult<T>? r;
      switch (q.type) {
        case EnumQueryType.add:
          r = col.addAll(q);
        case EnumQueryType.update:
          r = col.update(q, isSingleTarget: false);
        case EnumQueryType.updateOne:
          r = col.update(q, isSingleTarget: true);
        case EnumQueryType.delete:
          r = col.delete(q);
        case EnumQueryType.deleteOne:
          r = col.deleteOne(q);
        case EnumQueryType.search:
          r = col.search(q);
        case EnumQueryType.getAll:
          r = col.getAll(q);
        case EnumQueryType.conformToTemplate:
          r = col.conformToTemplate(q);
        case EnumQueryType.renameField:
          r = col.renameField(q);
        case EnumQueryType.count:
          r = col.count(q);
        case EnumQueryType.clear:
          r = col.clear(q);
        case EnumQueryType.clearAdd:
          r = col.clearAdd(q);
      }
      switch (q.type) {
        case EnumQueryType.add:
        case EnumQueryType.update:
        case EnumQueryType.updateOne:
        case EnumQueryType.delete:
        case EnumQueryType.deleteOne:
        case EnumQueryType.conformToTemplate:
        case EnumQueryType.renameField:
        case EnumQueryType.clear:
        case EnumQueryType.clearAdd:
          if (q.mustAffectAtLeastOne) {
            if (r.updateCount == 0) {
              return QueryResult<T>(
                isSuccess: false,
                type: q.type,
                result: [],
                dbLength: col.raw.length,
                updateCount: 0,
                hitCount: r.hitCount,
                errorMessage:
                    "No data matched the condition (mustAffectAtLeastOne=true).",
              );
            } else {
              return r;
            }
          } else {
            return r;
          }
        case EnumQueryType.search:
        case EnumQueryType.getAll:
        case EnumQueryType.count:
          return r;
      }
    } on ArgumentError catch (e) {
      return QueryResult<T>(
        isSuccess: false,
        type: q.type,
        result: [],
        dbLength: col.raw.length,
        updateCount: -1,
        hitCount: -1,
        errorMessage: e.message.toString(),
      );
    } catch (e) {
      print(className + ",executeQuery: " + e.toString());
      return QueryResult<T>(
        isSuccess: false,
        type: q.type,
        result: [],
        dbLength: col.raw.length,
        updateCount: -1,
        hitCount: -1,
        errorMessage: "Unexpected Error",
      );
    }
  }

  /// (en) Execute the transaction query.
  /// Server side, verify that the call is legitimate
  /// (e.g. by checking the JWT and/or the caller's user permissions)
  /// before making this call.
  /// During a transaction, after all operations are completed successfully,
  /// if there is a listener callback for each collection, it will be invoked.
  /// If there is a failure, nothing will be done.
  ///
  /// (ja) トランザクションクエリを実行します。
  /// サーバーサイドでは、この呼び出しの前に正規の呼び出しであるかどうかの
  /// 検証(JWTのチェックや呼び出し元ユーザーの権限のチェック)を行ってください。
  /// トランザクション時は、全ての処理が正常に完了後、各コレクションに
  /// リスナーのコールバックがあれば起動し、失敗の場合はなにもしません。
  TransactionQueryResult<T> executeTransactionQuery<T>(TransactionQuery q) {
    List<QueryResult> rq = [];
    try {
      // 一時的に保存が必要なコレクションを計算してバッファします。
      Map<String, Map<String, dynamic>> buff = {};
      for (Query i in q.queries) {
        if (buff.containsKey(i.target)) {
          continue;
        } else {
          buff[i.target] = collectionToDict(i.target);
          // コレクションをトランザクションモードに変更する。
          collection(i.target).changeTransactionMode(true);
        }
      }
      // クエリを実行します。
      try {
        for (Query i in q.queries) {
          rq.add(executeQuery(i));
        }
      } catch (e) {
        // エラーの場合は全ての変更を元に戻し、エラー扱いにします。
        // DBの変更を元に戻す。
        for (String key in buff.keys) {
          collectionFromDictKeepListener(key, buff[key]!);
          // 念の為確実にfalseにする。
          collection(key).changeTransactionMode(false);
        }
        print(className + ",executeTransactionQuery: Transaction failed");
        return TransactionQueryResult(
          isSuccess: false,
          results: [],
          errorMessage: "Transaction failed",
        );
      }
      // 問題がある場合は全ての変更を元に戻し、エラー扱いにします。
      for (QueryResult i in rq) {
        if (i.isSuccess == false) {
          // DBの変更を元に戻す。
          for (String key in buff.keys) {
            collectionFromDictKeepListener(key, buff[key]!);
            // 念の為確実にfalseにする。
            collection(key).changeTransactionMode(false);
          }
          print(className + ",executeTransactionQuery: Transaction failed");
          return TransactionQueryResult(
            isSuccess: false,
            results: [],
            errorMessage: "Transaction failed",
          );
        }
      }
      // コールバックが必要なコレクションのリスト。
      List<String> needCallbackCollections = [];
      // 問題がなければトランザクションモードを解除し、
      // 適切にコールバックを処理してから返します。
      for (String key in buff.keys) {
        // コールバックが必要なコレクション名を保存。
        if (collection(key).runNotifyListenersInTransaction) {
          needCallbackCollections.add(key);
        }
        collection(key).changeTransactionMode(false);
      }
      // 必要なものについてはコールバックを実行する。
      for (String key in needCallbackCollections) {
        collection(key).notifyListeners();
      }
      return TransactionQueryResult(isSuccess: true, results: rq);
    } catch (e) {
      print(className + ",executeTransactionQuery: " + e.toString());
      return TransactionQueryResult(
        isSuccess: false,
        results: [],
        errorMessage: "Unexpected Error",
      );
    }
  }
}
