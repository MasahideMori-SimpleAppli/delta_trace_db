import 'package:file_state_manager/file_state_manager.dart';
import 'package:logging/logging.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

final Logger _logger = Logger('delta_trace_db.db.delta_trace_db_core');

/// (en) It is an in-memory database that takes into consideration the
/// safety of various operations.
/// It was created with the assumption that in addition to humans,
/// AI will also be the main users.
///
/// (ja) 様々な操作の安全性を考慮したインメモリデータベースです。
/// 人間以外で、AIも主な利用者であると想定して作成しています。
class DeltaTraceDatabase extends CloneableFile {
  static const String className = "DeltaTraceDatabase";
  static const String version = "16";

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
  ///
  /// Throws on [FormatException] if the [src] is invalid format.
  DeltaTraceDatabase.fromDict(Map<String, dynamic> src)
    : _collections = _parseCollections(src);

  /// (en) Restoring database data from JSON.
  ///
  /// (ja) データベースのJSONからの復元処理。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  ///
  /// Throws on [FormatException] if the [src] is invalid format.
  static Map<String, Collection> _parseCollections(Map<String, dynamic> src) {
    final cols = src["collections"];
    if (cols is! Map<String, dynamic>) {
      throw FormatException(
        "Invalid format: 'collections' should be a Map<String, dynamic>.",
      );
    }
    final Map<String, Collection> r = {};
    for (final entry in cols.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        throw FormatException("Invalid format: target is not a Map.");
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

  /// (en) Find the specified collection.
  /// Returns it if it exists, otherwise returns null.
  ///
  /// (ja) 指定のコレクションを検索します。
  /// 存在すれば返し、存在しなければ null を返します。
  ///
  /// * [name] : The collection name.
  Collection? findCollection(String name) {
    if (_collections.containsKey(name)) {
      return _collections[name] as Collection;
    }
    return null;
  }

  /// (en) Deletes the specified collection.
  /// If a collection with the specified name does not exist, this does nothing.
  ///
  /// (ja) 指定のコレクションを削除します。
  /// 指定の名前のコレクションが存在しなかった場合は何もしません。
  ///
  /// * [name] : The collection name.
  void removeCollection(String name) {
    _collections.remove(name);
  }

  /// (en) Saves individual collections as dictionaries.
  /// For example, you can use this if you want to store a specific collection
  /// in an encrypted format.
  /// If you specify a collection that does not exist, null is returned.
  ///
  /// (ja) 個別のコレクションを辞書として保存します。
  /// 特定のコレクション単位で暗号化して保存したいような場合に利用できます。
  /// 存在しないコレクションを指定した場合はnullが返されます。
  ///
  /// * [name] : The collection name.
  Map<String, dynamic>? collectionToDict(String name) =>
      _collections[name]?.toDict();

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
  ///
  /// Throws on [FormatException] if the [src] is invalid format.
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
  ///
  /// Throws on [FormatException] if the [src] is invalid format.
  Collection collectionFromDictKeepListener(
    String name,
    Map<String, dynamic> src,
  ) {
    final col = Collection.fromDict(src);
    Set<void Function()>? listenersBuf = _collections[name]?.listeners;
    Map<String, void Function()>? namedListenersBuf =
        _collections[name]?.namedListeners;
    _collections[name] = col;
    if (listenersBuf != null) {
      _collections[name]!.listeners = listenersBuf;
    }
    if (namedListenersBuf != null) {
      _collections[name]!.namedListeners = namedListenersBuf;
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
  /// * [name] : If you set a non-null value, a listener will be registered
  /// with that name.
  /// Setting a name is useful if you want to be more precise about
  /// registration and release.
  void addListener(String target, void Function() cb, {String? name}) {
    Collection col = collection(target);
    col.addListener(cb, name: name);
  }

  /// (en) This function is used to cancel the set callback.
  /// Call it in the UI using dispose etc.
  ///
  /// (ja) 設定したコールバックを解除するための関数です。
  /// UIではdisposeなどで呼び出します。
  ///
  /// * [target] : The target collection name.
  /// * [cb] : The function for which you want to cancel the notification.
  /// * [name] : If you registered with a name when you added Listener,
  /// you must unregister with the same name.
  void removeListener(String target, void Function() cb, {String? name}) {
    Collection col = collection(target);
    col.removeListener(cb, name: name);
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
  ///
  /// * [query] : Query, TransactionQuery or Map\<String, dynamic\>.
  /// * [collectionPermissions] : Collection level operation permissions for
  /// the executing user. This is an optional argument for the server,
  /// the key is the target collection name.
  /// Use null on the frontend, if this is null then everything is allowed.
  ///
  /// Throws on [ArgumentError] if the [query] is unsupported type.
  QueryExecutionResult executeQueryObject(
    Object query, {
    Map<String, Permission>? collectionPermissions,
  }) {
    if (query is Query) {
      return executeQuery(query, collectionPermissions: collectionPermissions);
    } else if (query is TransactionQuery) {
      return executeTransactionQuery(
        query,
        collectionPermissions: collectionPermissions,
      );
    } else if (query is Map<String, dynamic>) {
      if (query["className"] == "Query") {
        return executeQuery(
          Query.fromDict(query),
          collectionPermissions: collectionPermissions,
        );
      } else if (query["className"] == "TransactionQuery") {
        return executeTransactionQuery(
          TransactionQuery.fromDict(query),
          collectionPermissions: collectionPermissions,
        );
      } else {
        throw ArgumentError("Unsupported query class");
      }
    } else {
      throw ArgumentError("Unsupported query type");
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
  ///
  /// * [q] : The query.
  /// * [collectionPermissions] : Collection level operation permissions for
  /// the executing user. This is an optional argument for the server,
  /// the key is the target collection name.
  /// Use null on the frontend, if this is null then everything is allowed.
  QueryResult<T> executeQuery<T>(
    Query q, {
    Map<String, Permission>? collectionPermissions,
  }) {
    // パーミッションのチェック。
    if (!UtilQuery.checkPermissions(q, collectionPermissions)) {
      return QueryResult<T>(
        isSuccess: false,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: -1,
        updateCount: 0,
        hitCount: 0,
        errorMessage: "Operation not permitted.",
      );
    }
    final bool isExistCol = _collections.containsKey(q.target);
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
        case EnumQueryType.searchOne:
          r = col.searchOne(q);
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
        case EnumQueryType.removeCollection:
          if (isExistCol) {
            r = QueryResult<T>(
              isSuccess: true,
              target: q.target,
              type: q.type,
              result: [],
              dbLength: 0,
              updateCount: 1,
              hitCount: 0,
              errorMessage: null,
            );
          } else {
            r = QueryResult<T>(
              isSuccess: true,
              target: q.target,
              type: q.type,
              result: [],
              dbLength: 0,
              updateCount: 0,
              hitCount: 0,
              errorMessage: null,
            );
          }
          removeCollection(q.target);
        case EnumQueryType.merge:
          r = _executeMergeQuery(q);
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
        case EnumQueryType.removeCollection:
        case EnumQueryType.merge:
          if (q.mustAffectAtLeastOne) {
            if (r.updateCount == 0) {
              if (r.isSuccess == false) {
                //　既に別のエラーが返されている場合。
                return r;
              } else {
                return QueryResult<T>(
                  isSuccess: false,
                  target: q.target,
                  type: q.type,
                  result: [],
                  dbLength: col.raw.length,
                  updateCount: 0,
                  hitCount: r.hitCount,
                  errorMessage:
                      "No data matched the condition (mustAffectAtLeastOne=true).",
                );
              }
            } else {
              return r;
            }
          } else {
            return r;
          }
        case EnumQueryType.search:
        case EnumQueryType.searchOne:
        case EnumQueryType.getAll:
        case EnumQueryType.count:
          return r;
      }
    } on ArgumentError catch (e, stack) {
      _logger.severe("executeQuery ArgumentError", e, stack);
      return QueryResult<T>(
        isSuccess: false,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: col.raw.length,
        updateCount: -1,
        hitCount: -1,
        errorMessage: "executeQuery ArgumentError",
      );
    } catch (e, stack) {
      _logger.severe("executeQuery Unexpected Error", e, stack);
      return QueryResult<T>(
        isSuccess: false,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: col.raw.length,
        updateCount: -1,
        hitCount: -1,
        errorMessage: "executeQuery Unexpected Error",
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
  /// removeCollection and merge queries cannot be executed and will return an
  /// error message if they are included in a transaction.
  ///
  /// (ja) トランザクションクエリを実行します。
  /// サーバーサイドでは、この呼び出しの前に正規の呼び出しであるかどうかの
  /// 検証(JWTのチェックや呼び出し元ユーザーの権限のチェック)を行ってください。
  /// トランザクション時は、全ての処理が正常に完了後、各コレクションに
  /// リスナーのコールバックがあれば起動し、失敗の場合はなにもしません。
  /// removeCollection及びmergeクエリは実行できず、
  /// トランザクションに含まれる場合はエラーメッセージが返されます。
  ///
  /// * [q] : The query.
  /// * [collectionPermissions] : Collection level operation permissions for
  /// the executing user. This is an optional argument for the server,
  /// the key is the target collection name.
  /// Use null on the frontend, if this is null then everything is allowed.
  TransactionQueryResult executeTransactionQuery(
    TransactionQuery q, {
    Map<String, Permission>? collectionPermissions,
  }) {
    // 許可されていないクエリが混ざっていないか調査し、混ざっていたら失敗にする。
    for (Query i in q.queries) {
      if (i.type == EnumQueryType.removeCollection ||
          i.type == EnumQueryType.merge) {
        return TransactionQueryResult(
          isSuccess: false,
          results: [],
          errorMessage:
              "The query contains a type that is not permitted to be executed within a transaction.",
        );
      }
    }
    // トランザクション付き処理を開始。
    List<QueryResult> rq = [];
    try {
      // 一時的に保存が必要なコレクションを計算してバッファします。
      Map<String, Map<String, dynamic>> buff = {};
      Set<String> nonExistTargets = {};
      for (Query i in q.queries) {
        if (buff.containsKey(i.target)) {
          continue;
        } else {
          Map<String, dynamic>? tCollection = collectionToDict(i.target);
          if (tCollection != null) {
            buff[i.target] = tCollection;
            // コレクションをトランザクションモードに変更する。
            collection(i.target).changeTransactionMode(true);
          } else {
            nonExistTargets.add(i.target);
          }
        }
      }
      // クエリを実行します。
      try {
        for (Query i in q.queries) {
          rq.add(executeQuery(i, collectionPermissions: collectionPermissions));
        }
      } catch (e, stack) {
        // エラーの場合は全ての変更を元に戻し、エラー扱いにします。
        _logger.severe("executeTransactionQuery failed", e, stack);
        return _rollbackCollections(buff, nonExistTargets);
      }
      // 問題がある場合は全ての変更を元に戻し、エラー扱いにします。
      for (QueryResult i in rq) {
        if (i.isSuccess == false) {
          return _rollbackCollections(buff, nonExistTargets);
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
    } catch (e, stack) {
      _logger.severe("executeTransactionQuery failed", e, stack);
      return TransactionQueryResult(
        isSuccess: false,
        results: [],
        errorMessage: "Unexpected Error",
      );
    }
  }

  /// (en) Rollback db.
  ///
  /// (ja) DBをロールバックします。
  ///
  /// * [buff] : The collection buffer that needs to be undone.
  /// * [nonExistTargets] : A list of collections that did not exist before the operation.
  TransactionQueryResult _rollbackCollections(
    Map<String, Map<String, dynamic>> buff,
    Set<String> nonExistTargets,
  ) {
    // DBの変更を元に戻す。
    for (String key in buff.keys) {
      collectionFromDictKeepListener(key, buff[key]!);
      // 念の為確実にfalseにする。
      collection(key).changeTransactionMode(false);
    }
    // 操作前に存在しなかったコレクションは削除する。
    for (String key in nonExistTargets) {
      removeCollection(key);
    }
    _logger.severe("executeTransactionQuery, Transaction failed");
    return TransactionQueryResult(
      isSuccess: false,
      results: [],
      errorMessage: "Transaction failed",
    );
  }

  /// (en) Run merge query.
  ///
  /// (ja) マージクエリを実行します。
  ///
  /// * [q] : The query.
  QueryResult<T> _executeMergeQuery<T>(Query q) {
    MergeQueryParams? mqp = q.mergeQueryParams;
    if (mqp == null) {
      return QueryResult<T>(
        isSuccess: false,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: 0,
        updateCount: 0,
        hitCount: 0,
        errorMessage: "Argument error",
      );
    }
    // 捜査対象コレクションの存在チェック。
    if (findCollection(mqp.base) == null) {
      return QueryResult<T>(
        isSuccess: false,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: 0,
        updateCount: 0,
        hitCount: 0,
        errorMessage: "Base collection does not exist.",
      );
    }
    if (mqp.source.isNotEmpty) {
      for (String colName in mqp.source) {
        if (findCollection(colName) == null) {
          return QueryResult<T>(
            isSuccess: false,
            target: q.target,
            type: q.type,
            result: [],
            dbLength: 0,
            updateCount: 0,
            hitCount: 0,
            errorMessage: "Source collection does not exist.",
          );
        }
      }
    }
    if (mqp.serialBase != null) {
      if (findCollection(mqp.serialBase!) == null) {
        return QueryResult<T>(
          isSuccess: false,
          target: q.target,
          type: q.type,
          result: [],
          dbLength: 0,
          updateCount: 0,
          hitCount: 0,
          errorMessage: "Serial base collection does not exist.",
        );
      }
    }
    // フラグの設定がおかしい場合はエラー。
    if (mqp.sourceKeys != null) {
      if (mqp.sourceKeys!.isEmpty ||
          (mqp.source.length != mqp.sourceKeys!.length)) {
        return QueryResult<T>(
          isSuccess: false,
          target: q.target,
          type: q.type,
          result: [],
          dbLength: 0,
          updateCount: 0,
          hitCount: 0,
          errorMessage: "The relationKey or relationKeys setting is invalid.",
        );
      }
    }
    // 既に出力先コレクションが存在するならエラー。
    if (findCollection(mqp.output) != null) {
      return QueryResult<T>(
        isSuccess: false,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: 0,
        updateCount: 0,
        hitCount: 0,
        errorMessage: "The output collection already exists.",
      );
    }
    try {
      // DSLを解釈しながら新しいデータを生成する。
      List<Map<String, dynamic>> newData = [];
      // まず、マージ元のデータを取得する。
      final List<Map<String, dynamic>> baseCollection = findCollection(
        mqp.base,
      )!.raw;
      final List<List<Map<String, dynamic>>> sourceCollections = [];
      for (String sourceName in mqp.source) {
        sourceCollections.add(findCollection(sourceName)!.raw);
      }
      // テンプレートの構造に沿ってDSLで値を代入していく。
      for (final baseItem in baseCollection) {
        final List<Map<String, dynamic>> matchedSources =
            UtilDslEvaluator.resolveSourceItems(
              baseItem,
              sourceCollections,
              mqp.relationKey,
              mqp.sourceKeys,
            );
        final Map<String, dynamic> newRow = UtilDslEvaluator.run(
          mqp.dslTmp,
          baseItem,
          matchedSources,
        );
        newData.add(newRow);
      }
      // 作成された新しいデータを新しいコレクションとして追加する。
      if (mqp.serialBase != null) {
        // シリアルナンバーの値を引き継ぐ。
        _collections[mqp.output] = Collection.fromData(
          newData,
          findCollection(mqp.serialBase!)!.getSerialNum(),
        );
      } else {
        // シリアルナンバーはserialKey依存で追加する。
        final addedResult = collection(mqp.output).addAll(
          RawQueryBuilder.add(
            target: mqp.output,
            rawAddData: newData,
            serialKey: mqp.serialKey,
          ).build(),
        );
        if (addedResult.isSuccess == false) {
          removeCollection(mqp.output);
          return QueryResult<T>(
            isSuccess: false,
            target: q.target,
            type: q.type,
            result: [],
            dbLength: 0,
            updateCount: 0,
            hitCount: 0,
            errorMessage: addedResult.errorMessage,
          );
        }
      }
      final Collection? resultCol = findCollection(mqp.output);
      return QueryResult<T>(
        isSuccess: true,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: resultCol?.length ?? 0,
        updateCount: resultCol?.length ?? 0,
        hitCount: 0,
      );
    } catch (e, stack) {
      // もし途中でエラーになった場合、outputのコレクションが生成されていたら削除して元に戻す。
      if (findCollection(mqp.output) != null) {
        removeCollection(mqp.output);
      }
      _logger.severe("executeMergeQuery failed", e, stack);
      return QueryResult<T>(
        isSuccess: false,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: 0,
        updateCount: 0,
        hitCount: 0,
        errorMessage: "Merge failed",
      );
    }
  }
}
