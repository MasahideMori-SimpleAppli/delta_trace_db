import 'package:collection/collection.dart';
import 'package:file_state_manager/file_state_manager.dart';

import '../../delta_trace_db.dart';

/// (en) An abstract class for classes related to the contents of
/// classes in the DB.
///
/// (ja) DB内のクラス単位の内容に関するクラスの抽象クラス。
abstract class CollectionBase extends CloneableFile {}

/// (en) This class relates to the contents of each class in the DB.
/// It implements operations on the DB.
///
/// (ja) DB内のクラス単位の内容に関するクラスです。
/// DBに対する操作などが実装されています。
class Collection extends CollectionBase {
  static const String className = "Collection";
  static const String version = "1";
  List<Map<String, dynamic>> _data = [];

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
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "data": (UtilCopy.jsonableDeepCopy(_data) as List)
          .cast<Map<String, dynamic>>(),
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

  /// (en) Adds the data specified by the query.
  ///
  /// (ja) クエリで指定されたデータを追加します。
  ///
  /// * [q] : The query.
  QueryResult<T> addAll<T>(Query q) {
    _data.addAll(
      (UtilCopy.jsonableDeepCopy(q.addData!) as List)
          .cast<Map<String, dynamic>>(),
    );
    return QueryResult<T>(
      isNoErrors: true,
      result: [],
      dbLength: _data.length,
      updateCount: 0,
      hitCount: 0,
    );
  }

  /// (en) Updates the contents of all objects that match the query.
  /// Only provided parameters will be overwritten;
  /// unprovided parameters will remain unchanged.
  ///
  /// (ja) クエリーにマッチする全てのオブジェクトの内容を更新します。
  /// 与えたパラメータのみが上書き対象になり、与えなかったパラメータは変化しません。
  ///
  /// * [q] : The query.
  QueryResult<T> update<T>(Query q) {
    if (q.returnData) {
      List<Map<String, dynamic>> r = [];
      for (int i = 0; i < _data.length; i++) {
        if (_evaluate(_data[i], q.queryNode!)) {
          _data[i].addAll(
            UtilCopy.jsonableDeepCopy(q.overrideData!) as Map<String, dynamic>,
          );
          r.add(_data[i]);
        }
      }
      if (q.sortObj != null) {
        r.sort(q.sortObj!.getComparator());
      }
      return QueryResult<T>(
        isNoErrors: true,
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
        }
      }
      return QueryResult<T>(
        isNoErrors: true,
        result: [],
        dbLength: _data.length,
        updateCount: count,
        hitCount: count,
      );
    }
  }

  /// (en) Updates the first object that matches the query.
  /// If you know there is only one object,
  /// such as when searching by serial number, this works faster than update.
  /// However, sorting is disabled, so please use this when there is
  /// only one item.
  ///
  /// (ja) クエリーにマッチするオブジェクトを最初の１件だけ更新します。
  /// シリアル番号を含めて探索している場合など、対象が１件であることが分かっている場合は
  /// updateよりも高速に動作します。
  /// ただしソートは無効なため、対象が１件だけである場合に使用してください。
  ///
  /// * [q] : The query.
  QueryResult<T> updateOne<T>(Query q) {
    if (q.returnData) {
      List<Map<String, dynamic>> r = [];
      for (int i = 0; i < _data.length; i++) {
        if (_evaluate(_data[i], q.queryNode!)) {
          _data[i].addAll(
            UtilCopy.jsonableDeepCopy(q.overrideData!) as Map<String, dynamic>,
          );
          r.add(_data[i]);
          return QueryResult<T>(
            isNoErrors: true,
            result: (UtilCopy.jsonableDeepCopy(r) as List)
                .cast<Map<String, dynamic>>(),
            dbLength: _data.length,
            updateCount: r.length,
            hitCount: r.length,
          );
        }
      }
      return QueryResult<T>(
        isNoErrors: true,
        result: [],
        dbLength: _data.length,
        updateCount: 0,
        hitCount: 0,
      );
    } else {
      for (int i = 0; i < _data.length; i++) {
        if (_evaluate(_data[i], q.queryNode!)) {
          _data[i].addAll(
            UtilCopy.jsonableDeepCopy(q.overrideData!) as Map<String, dynamic>,
          );
          return QueryResult<T>(
            isNoErrors: true,
            result: [],
            dbLength: _data.length,
            updateCount: 1,
            hitCount: 1,
          );
        }
      }
      return QueryResult<T>(
        isNoErrors: true,
        result: [],
        dbLength: _data.length,
        updateCount: 0,
        hitCount: 0,
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
      final List<Map<String, dynamic>> deletedItems = [];
      _data.removeWhere((item) {
        final shouldDelete = _evaluate(item, q.queryNode!);
        if (shouldDelete) {
          deletedItems.add(item);
        }
        return shouldDelete;
      });
      if (q.sortObj != null) {
        deletedItems.sort(q.sortObj!.getComparator());
      }
      return QueryResult<T>(
        isNoErrors: true,
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
          count += 1;
        }
        return shouldDelete;
      });
      return QueryResult<T>(
        isNoErrors: true,
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
    if (q.sortObj != null) {
      final sorted = [...r];
      sorted.sort(q.sortObj!.getComparator());
      r = sorted;
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
    }
    if (q.limit != null) {
      if (q.endBefore != null) {
        r = r.length > q.limit! ? r.sublist(r.length - q.limit!) : r;
      } else {
        r = r.take(q.limit!).toList();
      }
    }
    return QueryResult<T>(
      isNoErrors: true,
      result: (UtilCopy.jsonableDeepCopy(r) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: 0,
      hitCount: hitCount,
    );
  }

  /// (en) Gets all the contents of the collection.
  /// This is useful if you just want to sort the contents.
  ///
  /// (ja) コレクションの内容を全件取得します。
  /// 内容をソートだけしたいような場合に便利です。
  ///
  /// * [q] : The query.
  QueryResult<T> getAll<T>(Query q) {
    List<Map<String, dynamic>> r = [];
    r.addAll(_data);
    final int hitCount = r.length;
    // ソートのオプション
    if (q.sortObj != null) {
      final sorted = [...r];
      sorted.sort(q.sortObj!.getComparator());
      r = sorted;
    }
    return QueryResult<T>(
      isNoErrors: true,
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
    return QueryResult<T>(
      isNoErrors: true,
      result: [],
      dbLength: _data.length,
      updateCount: _data.length,
      hitCount: _data.length,
    );
  }

  /// (en) Renames the specified key in the database.
  ///
  /// (ja) データベースの、指定したキーの名前を変更します。
  ///
  /// * [q] : The query.
  QueryResult<T> renameField<T>(Query q) {
    int updateCount = 0;
    List<Map<String, dynamic>> r = [];
    for (Map<String, dynamic> item in _data) {
      if (!item.containsKey(q.renameBefore!)) {
        return QueryResult<T>(
          isNoErrors: false,
          result: (UtilCopy.jsonableDeepCopy(r) as List)
              .cast<Map<String, dynamic>>(),
          dbLength: _data.length,
          updateCount: updateCount,
          hitCount: updateCount,
          errorMessage: 'The target key does not exist. key:${q.renameBefore!}',
        );
      }
      if (item.containsKey(q.renameAfter!)) {
        return QueryResult<T>(
          isNoErrors: false,
          result: (UtilCopy.jsonableDeepCopy(r) as List)
              .cast<Map<String, dynamic>>(),
          dbLength: _data.length,
          updateCount: updateCount,
          hitCount: updateCount,
          errorMessage:
              'An existing key was specified as the new key. key:${q.renameAfter!}',
        );
      }
      item[q.renameAfter!] = item[q.renameBefore!];
      item.remove(q.renameBefore!);
      updateCount += 1;
      if (q.returnData) {
        r.add(item);
      }
    }
    return QueryResult<T>(
      isNoErrors: true,
      result: (UtilCopy.jsonableDeepCopy(r) as List)
          .cast<Map<String, dynamic>>(),
      dbLength: _data.length,
      updateCount: updateCount,
      hitCount: updateCount,
    );
  }

  /// (en) Returns the total number of records stored in the database.
  ///
  /// (ja) データベースに保存されているデータの総数を返します。
  QueryResult<T> count<T>() {
    return QueryResult<T>(
      isNoErrors: true,
      result: [],
      dbLength: _data.length,
      updateCount: 0,
      hitCount: _data.length,
    );
  }

  /// (en) Clear the contents of the database.
  ///
  /// (ja) データベースの保存内容を破棄します。
  QueryResult<T> clear<T>() {
    final int preLen = _data.length;
    _data.clear();
    return QueryResult<T>(
      isNoErrors: true,
      result: [],
      dbLength: 0,
      updateCount: preLen,
      hitCount: preLen,
    );
  }

  /// (en) Clear the contents stored in the database and then adds them.
  /// This can be used, for example, to update a front-end database with
  /// search results from a back-end.
  ///
  /// (ja) データベースの保存内容を破棄してから追加します。
  /// これは例えば、バックエンドからの検索内容でフロントエンドのDBを更新したい場合などに
  /// 使用できます。
  ///
  /// * [q] : The query.
  QueryResult<T> clearAdd<T>(Query q) {
    final int preLen = _data.length;
    _data.clear();
    _data.addAll(
      (UtilCopy.jsonableDeepCopy(q.addData!) as List)
          .cast<Map<String, dynamic>>(),
    );
    return QueryResult<T>(
      isNoErrors: true,
      result: [],
      dbLength: _data.length,
      updateCount: preLen,
      hitCount: preLen,
    );
  }

  /// クエリの評価関数。
  bool _evaluate(Map<String, dynamic> record, QueryNode node) =>
      node.evaluate(record);
}
