import 'package:file_state_manager/file_state_manager.dart';
import 'package:collection/collection.dart';
import '../../../delta_trace_db.dart';

/// (en) This class defines the information of the person who
/// requested the database operation.
///
/// (ja) データベースの操作をリクエストした者の情報を定義するクラスです。
class Actor extends CloneableFile {
  static const String className = "Actor";
  static const String version = "1";
  final EnumActorType type;
  final String id;

  // Actorが「何者であるか」を示すビジネス上の役割。
  final List<String> roles;

  // Actorが「何ができるか」を示す具体的な操作権限。命名規則はリソース:アクション:スコープ。
  final List<String> permissions;

  // コレクション単位の操作に関するパーミッション。
  final Map<String, Permission>? collectionPermissions;

  Map<String, dynamic>? context;

  /// * [type] : The actor type. Choose from HUMAN, AI, or SYSTEM.
  /// * [id] : The serial id (user id) of the actor.
  /// * [roles] : A business role that describes who an actor "is."
  /// * [permissions] : Specific operational permissions that indicate
  /// "what an actor can do." The naming convention is resource:action:scope.
  /// e.g. users:read:all => read all user information.
  /// * [collectionPermissions] : Collection-level permissions that relate only
  /// to database operations. The key is the collection name.
  /// * [context] : other context.
  Actor(
    this.type,
    this.id,
    this.roles,
    this.permissions, {
    this.collectionPermissions,
    this.context,
  });

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
      (src["roles"] as List).cast<String>(),
      (src["permissions"] as List).cast<String>(),
      collectionPermissions: collectionPermissions,
      context: src["context"] != null
          ? src["context"] as Map<String, dynamic>
          : null,
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
      "roles": roles,
      "permissions": permissions,
      "collectionPermissions": mCollectionPermissions,
      "context": UtilCopy.jsonableDeepCopy(context),
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is Actor) {
      return type == other.type &&
          id == other.id &&
          UnorderedIterableEquality().equals(roles, other.roles) &&
          UnorderedIterableEquality().equals(permissions, other.permissions) &&
          DeepCollectionEquality().equals(
            collectionPermissions,
            other.collectionPermissions,
          ) &&
          DeepCollectionEquality().equals(context, other.context);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return Object.hashAll([
      type,
      id,
      UtilObjectHash.calcList(roles),
      UtilObjectHash.calcList(permissions),
      context != null ? UtilObjectHash.calcMap(context!) : 0,
    ]);
  }
}
