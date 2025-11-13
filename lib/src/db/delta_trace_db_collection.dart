import 'package:collection/collection.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:logging/logging.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

final Logger _logger = Logger('delta_trace_db.db.delta_trace_db_collection');

/// (en) This class relates to the contents of each class in the DB.
/// It implements operations on the DB.
///
/// (ja) DB内のクラス単位の内容に関するクラスです。
/// DBに対する操作などが実装されています。
class Collection extends CloneableFile {
  static const String className = "Collection";
  static const String version = "16";
  List<Map<String, dynamic>> _data = [];

  /// A serial number is automatically assigned when a serial key is specified.
  /// It is automatically incremented and saved as the DB status.
  int _serialNum = 0;

  /// A set of callbacks to notify when linking with the UI, etc.
  Set<void Function()> listeners = {};
  Map<String, void Function()> namedListeners = {};

  /// A flag that is true only during a transaction.
  /// When this is ON, notifications will not be delivered.
  bool _isTransactionMode = false;

  /// True if notification is required at the end of the transaction.
  /// This is intended to be called only from DeltaTraceDB.
  /// Do not normally use this.
  bool runNotifyListenersInTransaction = false;

  /// (en) Called when switching to or from transaction mode.
  /// This is intended to be called only from DeltaTraceDB.
  /// Do not normally use this.
  ///
  /// (ja) トランザクションモードへの変更時、及び解除時に呼び出します。
  /// これはDeltaTraceDBからのみ呼び出されることを想定しています。
  /// 通常は使用しないでください。
  ///
  /// * [isTransactionMode] :  If true, change to transaction mode.
  void changeTransactionMode(bool isTransactionMode) {
    if (isTransactionMode) {
      _isTransactionMode = true;
      runNotifyListenersInTransaction = false;
    } else {
      _isTransactionMode = false;
      runNotifyListenersInTransaction = false;
    }
  }

  /// (en) The constructor.
  ///
  /// (ja) コンストラクタ。
  Collection();

  /// (en) Restore this object from the dictionary.
  /// Note that src is used as is, not copied.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  /// srcはコピーされずにそのまま利用されることに注意してください。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  Collection.fromDict(Map<String, dynamic> src) {
    _data = (src["data"] as List).cast<Map<String, dynamic>>();
    _serialNum = src.containsKey("serialNum") ? src["serialNum"] : 0;
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "data": (UtilCopy.jsonableDeepCopy(_data) as List)
          .cast<Map<String, dynamic>>(),
      "serialNum": _serialNum,
    };
  }

  @override
  Collection clone() {
    return Collection.fromDict(toDict());
  }

  /// (en) Returns the stored contents as a reference list.
  /// Be careful as it is dangerous to edit it directly.
  ///
  /// (ja) 保持している内容をリストの参照として返します。
  /// 直接編集すると危険なため注意してください。
  List<Map<String, dynamic>> get raw => _data;

  /// (en) Returns the number of data in the collection.
  ///
  /// (ja) コレクションのデータ数を返します。
  int get length => _data.length;

  /// (en) This is a callback setting function that can be used when linking
  /// the UI and DB.
  /// The callback set here will be called when the contents of this collection
  /// are changed.
  /// In other words, if you register it, you will be able to update the screen,
  /// etc. when the contents of the DB change.
  /// Normally you would register it in initState and then use removeListener
  /// to remove it when disposing.
  /// If you use this on the server side, it may be a good idea to set up a
  /// function that writes the backup to storage.
  /// Please note that notifications will not be restored even if the DB is
  /// deserialized. You will need to set them every time.
  ///
  /// Note: Listeners are not serialized.
  /// You must re-register them　each time after deserialization.
  ///
  /// (ja) UIとDBを連携する際に利用できる、コールバックの設定関数です。
  /// ここで設定したコールバックは、このコレクションの内容が変更されると呼び出されます。
  /// つまり、登録しておくとDBの内容変更時に画面更新等ができるようになります。
  /// 通常はinitStateで登録し、dispose時にremoveListenerを使って解除してください。
  /// これをサーバー側で使用する場合は、バックアップをストレージに書き込む関数などを設定
  /// するのも良いかもしれません。
  /// なお、通知に関してはDBをデシリアライズしても復元されません。毎回設定する必要があります。
  ///
  /// 注: リスナーはシリアライズされません。デシリアライズ後は毎回再登録する必要があります。
  ///
  /// * [cb] : The function to execute when the DB is changed.
  /// * [name] : If you set a non-null value, a listener will be registered
  /// with that name.
  /// Setting a name is useful if you want to be more precise about
  /// registration and release.
  void addListener(void Function() cb, {String? name}) {
    if (name == null) {
      listeners.add(cb);
    } else {
      namedListeners[name] = cb;
    }
  }

  /// (en) This function is used to cancel the set callback.
  /// Call it in the UI using dispose etc.
  ///
  /// (ja) 設定したコールバックを解除するための関数です。
  /// UIではdisposeなどで呼び出します。
  ///
  /// * [cb] : The function for which you want to cancel the notification.
  /// * [name] : If you registered with a name when you added Listener,
  /// you must unregister with the same name.
  void removeListener(void Function() cb, {String? name}) {
    if (name == null) {
      listeners.remove(cb);
    } else {
      namedListeners.remove(name);
    }
  }

  /// (en) Executes a registered callback.
  ///
  /// (ja) 登録済みのコールバックを実行します。
  void notifyListeners() {
    if (!_isTransactionMode) {
      for (final cb in listeners) {
        try {
          cb();
        } catch (e, stack) {
          _logger.severe("Callback in listeners failed", e, stack);
        }
      }

      for (final namedCb in namedListeners.values) {
        try {
          namedCb();
        } catch (e, stack) {
          _logger.severe("Callback in namedListeners failed", e, stack);
        }
      }
    } else {
      runNotifyListenersInTransaction = true;
    }
  }

  /// (en) The evaluation function for the query.
  ///
  /// (ja) クエリの評価関数。
  ///
  /// * [record] : Records (objects) to compare.
  /// * [node] : The node of the query to use for the comparison.
  ///
  /// Returns: If true, the query matches the item.
  bool _evaluate(Map<String, dynamic> record, QueryNode node) =>
      node.evaluate(record);

  /// (en) Adds the data specified by the query.
  /// If the key specified by serialKey does not exist
  /// in the object being added, the operation will fail.
  ///
  /// (ja) クエリで指定されたデータを追加します。
  /// serialKeyで指定したキーが追加するオブジェクトに存在しない場合、操作は失敗します。
  ///
  /// * [q] : The query.
  QueryResult<T> addAll<T>(Query q) {
    final addData = (UtilCopy.jsonableDeepCopy(q.addData!) as List)
        .cast<Map<String, dynamic>>();
    List<Map<String, dynamic>> addedItems = [];
    if (q.serialKey != null) {
      // 対象キーの存在チェック
      for (Map<String, dynamic> i in addData) {
        if (!i.containsKey(q.serialKey!)) {
          return QueryResult<T>(
            isSuccess: false,
            target: q.target,
            type: q.type,
            result: [],
            dbLength: _data.length,
            updateCount: 0,
            hitCount: 0,
            errorMessage: 'The target serialKey does not exist.',
          );
        }
      }
      for (Map<String, dynamic> i in addData) {
        final int serialNum = _serialNum;
        i[q.serialKey!] = serialNum;
        _serialNum++;
        _data.add(i);
        if (q.returnData) {
          addedItems.add(i);
        }
      }
    } else {
      _data.addAll(addData);
      if (q.returnData) {
        addedItems.addAll(addData);
      }
    }
    notifyListeners();
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: (UtilCopy.jsonableDeepCopy(addedItems) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: addData.length,
      hitCount: 0,
    );
  }

  /// (en) Updates the contents of all objects that match the query.
  /// Only provided parameters will be overwritten;
  /// unprovided parameters will remain unchanged.
  /// The parameters directly below will be updated.
  /// For example, if the original data is {"a": 0, "b": {"c": 1}},
  /// and you update it by data of {"b": {"d": 2}},
  /// the result will be {"a": 0, "b": {"d": 2}}.
  ///
  /// (ja) クエリーにマッチする全てのオブジェクトの内容を更新します。
  /// 与えたパラメータのみが上書き対象になり、与えなかったパラメータは変化しません。
  /// 直下のパラメータが更新対象になるため、
  /// 例えば元のデータが {"a" : 0 , "b" : {"c" : 1} }の場合に、
  /// {"b" : {"d" : 2} }で更新すると、
  /// 結果は {"a" : 0, "b" : {"d" : 2} } になります。
  ///
  /// * [q] : The query.
  /// * [isSingleTarget] : If true, the target is single object.
  QueryResult<T> update<T>(Query q, {required bool isSingleTarget}) {
    if (q.returnData) {
      List<Map<String, dynamic>> r = [];
      for (int i = 0; i < _data.length; i++) {
        if (_evaluate(_data[i], q.queryNode!)) {
          _data[i].addAll(
            UtilCopy.jsonableDeepCopy(q.overrideData!) as Map<String, dynamic>,
          );
          r.add(_data[i]);
          if (isSingleTarget) break;
        }
      }
      r = _applySort(q, r);
      if (r.isNotEmpty) {
        notifyListeners();
      }
      return QueryResult<T>(
        isSuccess: true,
        target: q.target,
        type: q.type,
        result: (UtilCopy.jsonableDeepCopy(r) as List)
            .cast<Map<String, dynamic>>(),
        dbLength: _data.length,
        updateCount: r.length,
        hitCount: r.length,
      );
    } else {
      int count = 0;
      for (int i = 0; i < _data.length; i++) {
        if (_evaluate(_data[i], q.queryNode!)) {
          _data[i].addAll(
            UtilCopy.jsonableDeepCopy(q.overrideData!) as Map<String, dynamic>,
          );
          count += 1;
          if (isSingleTarget) break;
        }
      }
      if (count > 0) {
        notifyListeners();
      }
      return QueryResult<T>(
        isSuccess: true,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: _data.length,
        updateCount: count,
        hitCount: count,
      );
    }
  }

  /// (en) Deletes all objects that match a query.
  ///
  /// (ja) クエリーにマッチするオブジェクトを全て削除します。
  ///
  /// * [q] : The query.
  QueryResult<T> delete<T>(Query q) {
    if (q.returnData) {
      List<Map<String, dynamic>> deletedItems = [];
      _data.removeWhere((item) {
        final shouldDelete = _evaluate(item, q.queryNode!);
        if (shouldDelete) {
          deletedItems.add(item);
        }
        return shouldDelete;
      });
      deletedItems = _applySort(q, deletedItems);
      if (deletedItems.isNotEmpty) {
        notifyListeners();
      }
      return QueryResult<T>(
        isSuccess: true,
        target: q.target,
        type: q.type,
        result: (UtilCopy.jsonableDeepCopy(deletedItems) as List)
            .cast<Map<String, dynamic>>(),
        dbLength: _data.length,
        updateCount: deletedItems.length,
        hitCount: deletedItems.length,
      );
    } else {
      int count = 0;
      _data.removeWhere((item) {
        final shouldDelete = _evaluate(item, q.queryNode!);
        if (shouldDelete) {
          count++;
        }
        return shouldDelete;
      });
      if (count > 0) {
        notifyListeners();
      }
      return QueryResult<T>(
        isSuccess: true,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: _data.length,
        updateCount: count,
        hitCount: count,
      );
    }
  }

  /// (en) Removes only the first object that matches the query.
  ///
  /// (ja) クエリーにマッチするオブジェクトのうち、最初の１つだけを削除します。
  ///
  /// * [q] : The query.
  QueryResult<T> deleteOne<T>(Query q) {
    if (q.returnData) {
      final List<Map<String, dynamic>> deletedItems = [];
      for (int i = 0; i < _data.length; i++) {
        final item = _data[i];
        final shouldDelete = _evaluate(item, q.queryNode!);
        if (shouldDelete) {
          deletedItems.add(item);
          _data.removeAt(i);
          break;
        }
      }
      if (deletedItems.isNotEmpty) {
        notifyListeners();
      }
      return QueryResult<T>(
        isSuccess: true,
        target: q.target,
        type: q.type,
        result: (UtilCopy.jsonableDeepCopy(deletedItems) as List)
            .cast<Map<String, dynamic>>(),
        dbLength: _data.length,
        updateCount: deletedItems.length,
        hitCount: deletedItems.length,
      );
    } else {
      int count = 0;
      for (int i = 0; i < _data.length; i++) {
        final item = _data[i];
        final shouldDelete = _evaluate(item, q.queryNode!);
        if (shouldDelete) {
          _data.removeAt(i);
          count++;
          break;
        }
      }
      if (count > 0) {
        notifyListeners();
      }
      return QueryResult<T>(
        isSuccess: true,
        target: q.target,
        type: q.type,
        result: [],
        dbLength: _data.length,
        updateCount: count,
        hitCount: count,
      );
    }
  }

  /// (en) Finds and returns objects that match a query.
  ///
  /// (ja) クエリーにマッチするオブジェクトを検索し、返します。
  ///
  /// * [q] : The query.
  QueryResult<T> search<T>(Query q) {
    List<Map<String, dynamic>> r = [];
    // 検索
    for (var i = 0; i < _data.length; i++) {
      if (_evaluate(_data[i], q.queryNode!)) {
        r.add(_data[i]);
      }
    }
    final int hitCount = r.length;
    // ソートやページングのオプション
    r = _sortPagingLimit(q, r);
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: (UtilCopy.jsonableDeepCopy(r) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: 0,
      hitCount: hitCount,
    );
  }

  /// (en) Sorting, paging, and limits are applied before returning the result.
  ///
  /// (ja) ソートとページング、リミットをそれぞれ適用して返します。
  ///
  /// * [q] : The query.
  /// * [preR] : Pre result.
  List<Map<String, dynamic>> _sortPagingLimit(
    Query q,
    List<Map<String, dynamic>> preR,
  ) {
    List<Map<String, dynamic>> r = preR;
    r = _applySort(q, r);
    r = _applyGetPosition(q, r);
    r = _applyLimit(q, r);
    return r;
  }

  /// (en) Apply sort.
  ///
  /// (ja) ソートを適用します。
  ///
  /// * [q] : The query.
  /// * [preR] : Pre result.
  List<Map<String, dynamic>> _applySort(
    Query q,
    List<Map<String, dynamic>> preR,
  ) {
    List<Map<String, dynamic>> r = preR;
    if (q.sortObj != null) {
      final sorted = [...r];
      sorted.sort(q.sortObj!.getComparator());
      r = sorted;
    }
    return r;
  }

  /// (en) Applies offset, startAfter, and endBefore.
  /// The priority of offset, startAfter,
  /// and endBefore is "offset > startAfter > endBefore".
  ///
  /// (ja) offset、startAfter、endBeforeを適用します。
  /// offset、startAfter、endBeforeの優先度は、offset > startAfter > endBeforeです。
  ///
  /// * [q] : The query.
  /// * [preR] : Pre result.
  List<Map<String, dynamic>> _applyGetPosition(
    Query q,
    List<Map<String, dynamic>> preR,
  ) {
    List<Map<String, dynamic>> r = preR;
    if (q.offset != null) {
      if (q.offset! > 0) {
        r = r.skip(q.offset!).toList();
      }
    } else {
      if (q.startAfter != null) {
        final equality = const DeepCollectionEquality();
        final index = r.indexWhere(
          (item) => equality.equals(item, q.startAfter),
        );
        if (index != -1 && index + 1 < r.length) {
          r = r.sublist(index + 1);
        } else if (index != -1 && index + 1 >= r.length) {
          r = [];
        }
      } else if (q.endBefore != null) {
        final equality = const DeepCollectionEquality();
        final index = r.indexWhere(
          (item) => equality.equals(item, q.endBefore),
        );
        if (index != -1) {
          r = r.sublist(0, index);
        }
      }
    }
    return r;
  }

  /// (en)Applies a limit. Behavior is as follows:
  /// - Normal: Return limit items from the beginning.
  /// - If endBefore is enabled: Return limit items from the end of the range.
  ///
  /// (ja) リミットを適用します。動作は以下の通りです。
  /// - 通常: 先頭から limit 件を返す。
  /// - endBefore が有効な場合: 対象範囲の末尾から limit 件を返す。
  ///
  /// * [q] : The query.
  /// * [preR] : Pre result.
  List<Map<String, dynamic>> _applyLimit(
    Query q,
    List<Map<String, dynamic>> preR,
  ) {
    List<Map<String, dynamic>> r = preR;
    if (q.limit == null) return r;
    if (q.offset == null && q.startAfter == null && q.endBefore != null) {
      return r.length > q.limit! ? r.sublist(r.length - q.limit!) : r;
    }
    return r.take(q.limit!).toList();
  }

  /// (en) Finds and returns objects that match a query.
  /// It is faster than a "search query" when searching for a single item
  /// because the search stops once a hit is found.
  ///
  /// (ja) クエリーにマッチするオブジェクトを検索し、返します。
  /// 1件のヒットがあった時点で探索を打ち切るため、
  /// 単一のアイテムを検索する場合はsearchよりも高速に動作します。
  ///
  /// * [q] : The query.
  QueryResult<T> searchOne<T>(Query q) {
    List<Map<String, dynamic>> r = [];
    // 検索
    for (var i = 0; i < _data.length; i++) {
      if (_evaluate(_data[i], q.queryNode!)) {
        r.add(_data[i]);
        break;
      }
    }
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: (UtilCopy.jsonableDeepCopy(r) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: 0,
      hitCount: r.length,
    );
  }

  /// (en) Gets all the contents of the collection.
  /// This is useful if you just want to sort the contents.
  /// By specifying paging-related parameters,
  /// you can easily create paging through all items.
  ///
  /// (ja) コレクションの内容を全件取得します。
  /// 内容をソートだけしたいような場合に便利です。
  /// ページング関係のパラメータを指定することで、
  /// 全アイテムからのページングを簡単に作ることもできます。
  ///
  /// * [q] : The query.
  QueryResult<T> getAll<T>(Query q) {
    List<Map<String, dynamic>> r = [];
    r.addAll(_data);
    final int hitCount = r.length;
    // ソートやページングのオプション
    r = _sortPagingLimit(q, r);
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: (UtilCopy.jsonableDeepCopy(r) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: 0,
      hitCount: hitCount,
    );
  }

  /// (en) Changes the structure of the database according to
  /// the specified template.
  /// Keys and values that are not in the specified template are deleted.
  /// Keys that exist only in the specified template are added and
  /// initialized with the values from the template.
  ///
  /// (ja) データベースの構造を、指定のテンプレートに沿って変更します。
  /// 指定したテンプレートに無いキーと値は削除されます。
  /// 指定したテンプレートにのみ存在するキーは追加され、テンプレートの値で初期化されます。
  ///
  /// * [q] : The query.
  QueryResult<T> conformToTemplate<T>(Query q) {
    for (Map<String, dynamic> item in _data) {
      // 1. 削除処理：itemにあるがtmpに無いキーは削除
      final keysToRemove = item.keys
          .where((key) => !q.template!.containsKey(key))
          .toList();
      for (String key in keysToRemove) {
        item.remove(key);
      }
      // 2. 追加処理：tmpにあるがitemに無いキーを追加
      for (String key in q.template!.keys) {
        if (!item.containsKey(key)) {
          item[key] = UtilCopy.jsonableDeepCopy(q.template![key]);
        }
      }
    }
    notifyListeners();
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: [],
      dbLength: _data.length,
      updateCount: _data.length,
      hitCount: _data.length,
    );
  }

  /// (en) Renames the specified key in the database.
  /// The operation will fail if the target key does not exist or
  /// if you try to change it to an existing key.
  ///
  /// (ja) データベースの、指定したキーの名前を変更します。
  /// 対象のキーが存在しなかったり、既に存在するキーに変更しようとすると操作は失敗します。
  ///
  /// * [q] : The query.
  QueryResult<T> renameField<T>(Query q) {
    int updateCount = 0;
    List<Map<String, dynamic>> r = [];
    for (Map<String, dynamic> item in _data) {
      if (!item.containsKey(q.renameBefore!)) {
        return QueryResult<T>(
          isSuccess: false,
          target: q.target,
          type: q.type,
          result: [],
          dbLength: _data.length,
          updateCount: 0,
          hitCount: 0,
          errorMessage: 'The renameBefore key does not exist.',
        );
      }
      if (item.containsKey(q.renameAfter!)) {
        return QueryResult<T>(
          isSuccess: false,
          target: q.target,
          type: q.type,
          result: [],
          dbLength: _data.length,
          updateCount: 0,
          hitCount: 0,
          errorMessage: 'An existing key was specified as the new key',
        );
      }
    }
    for (Map<String, dynamic> item in _data) {
      item[q.renameAfter!] = item[q.renameBefore!];
      item.remove(q.renameBefore!);
      updateCount += 1;
      if (q.returnData) {
        r.add(item);
      }
    }
    notifyListeners();
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: (UtilCopy.jsonableDeepCopy(r) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: updateCount,
      hitCount: updateCount,
    );
  }

  /// (en) Returns the total number of items stored in the collection.
  ///
  /// (ja) コレクション内のデータの総数を返します。
  ///
  /// * [q] : The query.
  QueryResult<T> count<T>(Query q) {
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: [],
      dbLength: _data.length,
      updateCount: 0,
      hitCount: _data.length,
    );
  }

  /// (en) Clear the contents of the collection.
  ///
  /// (ja) コレクションの内容を破棄します。
  ///
  /// * [q] : The query.
  QueryResult<T> clear<T>(Query q) {
    final int preLen = _data.length;
    _data.clear();
    if (q.resetSerial) {
      _serialNum = 0;
    }
    notifyListeners();
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: [],
      dbLength: 0,
      updateCount: preLen,
      hitCount: preLen,
    );
  }

  /// (en) Clear the contents stored in the collection and then adds data.
  /// This can be used, for example, to update a front-end database with
  /// search results from a back-end.
  /// If the key specified by serialKey does not exist
  /// in the object being added, the operation will fail.
  ///
  /// (ja) コレクションの内容を破棄してからデータを追加します。
  /// これは例えば、バックエンドからの検索内容でフロントエンドのDBを更新したい場合などに
  /// 使用できます。
  /// serialKeyで指定したキーが追加するオブジェクトに存在しない場合、操作は失敗します。
  ///
  /// * [q] : The query.
  QueryResult<T> clearAdd<T>(Query q) {
    final addData = (UtilCopy.jsonableDeepCopy(q.addData!) as List)
        .cast<Map<String, dynamic>>();
    if (q.serialKey != null) {
      // 対象キーの存在チェック
      for (Map<String, dynamic> i in addData) {
        if (!i.containsKey(q.serialKey!)) {
          return QueryResult<T>(
            isSuccess: false,
            target: q.target,
            type: q.type,
            result: [],
            dbLength: _data.length,
            updateCount: 0,
            hitCount: 0,
            errorMessage: 'The target serialKey does not exist',
          );
        }
      }
    }
    final int preLen = _data.length;
    _data.clear();
    if (q.resetSerial) {
      _serialNum = 0;
    }
    List<Map<String, dynamic>> addedItems = [];
    if (q.serialKey != null) {
      for (Map<String, dynamic> i in addData) {
        final int serialNum = _serialNum;
        i[q.serialKey!] = serialNum;
        _serialNum++;
        _data.add(i);
        if (q.returnData) {
          addedItems.add(i);
        }
      }
    } else {
      _data.addAll(addData);
      if (q.returnData) {
        addedItems.addAll(addData);
      }
    }
    notifyListeners();
    return QueryResult<T>(
      isSuccess: true,
      target: q.target,
      type: q.type,
      result: (UtilCopy.jsonableDeepCopy(addedItems) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: preLen,
      hitCount: preLen,
    );
  }
}
