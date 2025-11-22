import 'package:file_state_manager/file_state_manager.dart';
import 'package:collection/collection.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) This class defines the information of the person who
/// requested the database operation.
///
/// (ja) データベースの操作をリクエストした者の情報を定義するクラスです。
class Actor extends CloneableFile {
  static const String className = "Actor";
  static const String version = "6";
  final EnumActorType type;
  final String id;

  // user data
  String? name;
  String? email;

  // Timestamps
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastAccess;

  // Access counting
  // lastAccessDay: the reference reset DateTime for daily counting.
  DateTime? lastAccessDay;

  // operationInDay: number of operations since lastAccessDay.
  int? operationInDay;

  // User device identifiers
  List<String>? deviceIds;

  // Collection-level permissions relevant only to database operations.
  final Map<String, Permission>? collectionPermissions;

  Map<String, dynamic>? context;

  /// * [type] : The actor type. Choose from HUMAN, AI, or SYSTEM.
  /// * [id] : The serial id (user id) of the actor.
  /// * [collectionPermissions] : Collection-level permissions that relate only
  /// to database operations. The key is the collection name.
  /// * [context] : The other context.
  /// * [name] : The actor's display name (optional).
  /// * [email] : The actor's email address (optional).
  /// * [createdAt] : The creation timestamp of this actor. If null,
  /// set to now (UTC).
  /// * [updatedAt] : The last update timestamp of this actor.
  /// If null, set to [createdAt].
  /// This parameter should only be overridden if the values of name, email,
  /// context, or deviceIds have changed.
  /// * [lastAccess] : The timestamp of the last database access by this actor.
  /// It will be updated when you call [updateAccess].
  /// * [lastAccessDay] : The start-of-day timestamp for counting
  /// daily operations.
  /// It will be updated when you call [updateAccess].
  /// * [operationInDay] : Number of operations performed by this actor
  /// since [lastAccessDay].
  /// If this parameter using, After creating an Actor instance,
  /// call [updateAccess] to record the first access and initialize
  /// daily operation count.
  /// * [deviceIds] : This is a list of device IDs that the user is using.
  Actor(
    this.type,
    this.id, {
    this.collectionPermissions,
    this.context,
    // added v6
    this.name,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.lastAccess,
    this.lastAccessDay,
    this.operationInDay,
    this.deviceIds,
  }) {
    createdAt ??= DateTime.now().toUtc();
    updatedAt ??= createdAt!.copyWith();
  }

  static DateTime? _parseDateTime(Map<String, dynamic> src, String key) {
    if (!src.containsKey(key)) return null;
    final v = src[key];
    if (v == null) return null;
    try {
      return DateTime.parse(v);
    } catch (e) {
      return null;
    }
  }

  static String? _parseString(Map<String, dynamic> src, String key) {
    if (!src.containsKey(key)) return null;
    try {
      return src[key] as String?;
    } catch (e) {
      return null;
    }
  }

  static int? _parseInt(Map<String, dynamic> src, String key) {
    if (!src.containsKey(key)) return null;
    try {
      return src[key] as int?;
    } catch (e) {
      return null;
    }
  }

  static String? _toIsoUtcString(DateTime? dt) => dt?.toUtc().toIso8601String();

  /// (en) Updates the access counter and last access date and time.
  /// Please note that updatedAt will not be updated.
  /// After creating an Actor instance, call this method to record the
  /// first access and initialize daily operation count.
  ///
  /// (ja) アクセスカウンタや最終アクセス日時を更新します。
  /// なお、updatedAtは更新されないことに注意してください。
  /// Actorインスタンスを作成した後、最初のアクセスを記録し
  /// 日次操作カウントを初期化するために、このメソッドを呼んでください。
  ///
  /// * [now] : Current time. If it is not UTC, it will be automatically
  /// converted to UTC.
  /// * [resetHour] : Specifies the time in UTC based on which the date and
  /// time count is updated.
  ///
  /// Throws on [ArgumentError]
  /// if the [resetHour] is invalid value (resetHour < 0 || resetHour > 23) .
  void updateAccess(DateTime now, {int resetHour = 5}) {
    if (resetHour < 0 || resetHour > 23) {
      throw ArgumentError('resetHour must be between 0 and 23');
    }
    // UTCに変換
    final utcNow = now.toUtc();
    // 今日のリセット時刻（UTC）
    final todayReset = DateTime.utc(
      utcNow.year,
      utcNow.month,
      utcNow.day,
      resetHour,
    );
    // 現在のリセット基準日を決定
    final currentResetBase = utcNow.isBefore(todayReset)
        ? todayReset.subtract(const Duration(days: 1))
        : todayReset;
    // リセットが必要か判定
    final needReset =
        lastAccessDay == null || lastAccessDay!.isBefore(currentResetBase);
    if (needReset) {
      operationInDay = 1;
      lastAccessDay = currentResetBase;
    } else {
      operationInDay = (operationInDay ?? 0) + 1;
    }
    // 最終アクセス日時を更新
    lastAccess = utcNow;
    // updatedAtは更新しない仕様
  }

  /// (en) Recover this class from the dictionary.
  ///
  /// (ja) 辞書からこのクラスを復元します。
  factory Actor.fromDict(Map<String, dynamic> src) {
    final Map<String, Map<String, dynamic>>? mCollectionPermissions =
        (src["collectionPermissions"] as Map<String, dynamic>?)
            ?.map<String, Map<String, dynamic>>(
              (k, v) => MapEntry(k, v as Map<String, dynamic>),
            );
    Map<String, Permission>? collectionPermissions;
    if (mCollectionPermissions != null) {
      collectionPermissions = {};
      for (String i in mCollectionPermissions.keys) {
        collectionPermissions[i] = Permission.fromDict(
          mCollectionPermissions[i]!,
        );
      }
    }
    return Actor(
      EnumActorType.values.byName(src["type"]),
      src["id"],
      collectionPermissions: collectionPermissions,
      context: src["context"] != null
          ? src["context"] as Map<String, dynamic>
          : null,
      name: _parseString(src, 'name'),
      email: _parseString(src, 'email'),
      createdAt: _parseDateTime(src, 'createdAt'),
      updatedAt: _parseDateTime(src, 'updatedAt'),
      lastAccess: _parseDateTime(src, 'lastAccess'),
      lastAccessDay: _parseDateTime(src, 'lastAccessDay'),
      operationInDay: _parseInt(src, 'operationInDay'),
      deviceIds: (src['deviceIds'] as List<dynamic>?)?.cast<String>(),
    );
  }

  @override
  Actor clone() {
    return Actor.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    Map<String, Map<String, dynamic>>? mCollectionPermissions;
    if (collectionPermissions != null) {
      mCollectionPermissions = {};
      for (String i in collectionPermissions!.keys) {
        mCollectionPermissions[i] = collectionPermissions![i]!.toDict();
      }
    }
    return {
      "className": className,
      "version": version,
      "type": type.name,
      "id": id,
      "collectionPermissions": mCollectionPermissions,
      "context": UtilCopy.jsonableDeepCopy(context),
      'name': name,
      'email': email,
      'createdAt': _toIsoUtcString(createdAt),
      'updatedAt': _toIsoUtcString(updatedAt),
      'lastAccess': _toIsoUtcString(lastAccess),
      'lastAccessDay': _toIsoUtcString(lastAccessDay),
      'operationInDay': operationInDay,
      'deviceIds': UtilCopy.jsonableDeepCopy(deviceIds),
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! Actor) return false;
    final listEq = ListEquality<String>();
    // createdAt, updatedAt, lastAccess, lastAccessDay, operationInDayは
    // ユーザーの同一性には影響しないため計算対象外。
    return type == other.type &&
        id == other.id &&
        DeepCollectionEquality().equals(
          collectionPermissions,
          other.collectionPermissions,
        ) &&
        DeepCollectionEquality().equals(context, other.context) &&
        name == other.name &&
        email == other.email &&
        listEq.equals(deviceIds, other.deviceIds);
  }

  @override
  int get hashCode {
    // createdAt, updatedAt, lastAccess, lastAccessDay, operationInDayは
    // ユーザーの同一性には影響しないため計算対象外。
    return Object.hashAll([
      type,
      id,
      collectionPermissions != null
          ? UtilObjectHash.calcMap(collectionPermissions!)
          : 0,
      context != null ? UtilObjectHash.calcMap(context!) : 0,
      name ?? '',
      email ?? '',
      deviceIds != null ? UtilObjectHash.calcList(deviceIds!) : 0,
    ]);
  }
}
