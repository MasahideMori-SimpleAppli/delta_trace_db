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
  late final EnumActorType type;
  late final String id;

  // Actorが「何者であるか」を示すビジネス上の役割。
  late final List<String> roles;

  // Actorが「何ができるか」を示す具体的な操作権限。命名規則はリソース:アクション:スコープ。
  late final List<String> permissions;

  Map<String, dynamic>? context;

  /// * [type] : The actor type. Choose from HUMAN, AI, or SYSTEM.
  /// * [id] : The serial id (user id) of the actor.
  /// * [roles] : A business role that describes who an actor "is."
  /// * [permissions] : Specific operational permissions that indicate
  /// "what an actor can do." The naming convention is resource:action:scope.
  /// e.g. users:read:all => read all user information.
  /// * [context] : other context.
  Actor(this.type, this.id, this.roles, this.permissions, {this.context});

  /// (en) Recover this class from the dictionary.
  ///
  /// (ja) 辞書からこのクラスを復元します。
  Actor.fromDict(Map<String, dynamic> src) {
    type = EnumActorType.values.byName(src["type"]);
    id = src["id"];
    roles = (src["roles"] as List).cast<String>();
    permissions = (src["permissions"] as List).cast<String>();
    context = src["context"] != null
        ? src["context"] as Map<String, dynamic>
        : null;
  }

  @override
  Actor clone() {
    return Actor.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "type": type.name,
      "id": id,
      "roles": roles,
      "permissions": permissions,
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
