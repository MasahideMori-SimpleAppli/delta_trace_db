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
  static const String version = "2";

  late final Map<String, CollectionBase> _collections;

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
  static Map<String, CollectionBase> _parseCollections(
    Map<String, dynamic> src,
  ) {
    final raw = src["collections"];
    if (raw is! Map<String, dynamic>) {
      throw FormatException(
        "Invalid format: 'collections' should be a Map<String, dynamic>.",
      );
    }
    final Map<String, CollectionBase> r = {};
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

  @override
  CloneableFile clone() {
    return DeltaTraceDatabase.fromDict(toDict());
  }

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
  /// The callback set here will be called when the contents of this collection
  /// are changed.
  /// In other words, if you register it, you will be able to update the screen,
  /// etc. when the contents of the DB change.
  /// Normally you would register it in initState and then use removeListener
  /// to remove it when disposing.
  /// If you use this on the server side, you can also set up a function to
  /// write the backup to storage.
  /// Please note that notifications will not be restored even if the DB is
  /// deserialized. You will need to set them every time.
  ///
  /// (ja) UIとDBを連携する際に利用できる、コールバックの設定関数です。
  /// ここで設定したコールバックは、このコレクションの内容が変更されると呼び出されます。
  /// つまり、登録しておくとDBの内容変更時に画面更新等ができるようになります。
  /// 通常はinitStateで登録し、dispose時にremoveListenerを使って解除してください。
  /// これをサーバー側で使用する場合は、バックアップをストレージに書き込む機能も設定できます。
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
      switch (q.type) {
        case EnumQueryType.add:
          return col.addAll(q);
        case EnumQueryType.update:
          return col.update(q);
        case EnumQueryType.updateOne:
          return col.updateOne(q);
        case EnumQueryType.delete:
          return col.delete(q);
        case EnumQueryType.search:
          return col.search(q);
        case EnumQueryType.getAll:
          return col.getAll(q);
        case EnumQueryType.conformToTemplate:
          return col.conformToTemplate(q);
        case EnumQueryType.renameField:
          return col.renameField(q);
        case EnumQueryType.count:
          return col.count();
        case EnumQueryType.clear:
          return col.clear();
        case EnumQueryType.clearAdd:
          return col.clearAdd(q);
      }
    } on ArgumentError catch (e) {
      return QueryResult<T>(
        isNoErrors: false,
        result: [],
        dbLength: col.raw.length,
        updateCount: -1,
        hitCount: -1,
        errorMessage: e.message.toString(),
      );
    }
  }
}
