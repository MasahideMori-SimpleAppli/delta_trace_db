import 'package:file_state_manager/file_state_manager.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) A class for entering a description of a query.
/// If you write this class accurately, you can log queries and
/// trace a nearly complete history of database operations.
/// It is recommended to include this class in queries in cases with
/// high security requirements.
///
/// (ja) クエリに関する説明を入力するためのクラスです。
/// このクラスを正確に記述する場合、クエリをログとして保存することで、
/// データベース操作のほぼ完全な歴史を辿ることが可能になります。
/// 高度なセキュリティ要件があるケースではこのクラスをクエリに含めることをお勧めします。
class Cause extends CloneableFile {
  static const String className = "Cause";
  static const String version = "1";

  String? serial;
  String? chainParentSerial;
  Actor who;
  TemporalTrace when;
  String what;
  String why;
  String from;
  Map<String, dynamic>? context;
  double confidenceScore;

  /// * [serial] : A unique identifier assigned to this operation.
  /// * [chainParentSerial] : The serial of the previous Cause,
  /// in case this operation is a chain operation.
  /// * [who] : Information about the person who performed the operation.
  /// * [when] : The "time trail" of the event.
  /// * [what] : An explanation of this inquiry,
  /// i.e., what kind of operation it is.
  /// Example: Obtaining data for a specified period on screen A.
  /// * [why] : An explanation of why this inquiry is being made.
  /// Example: Correcting a user's input error.
  /// * [from] : An explanation of where the inquiry is coming from.
  /// Example: From mobile app A.
  /// * [context] : Other more detailed information.
  /// * [confidenceScore] : A degree of confidence expressed as 0.0 to 1.0.
  /// When correcting an error, this indicates the degree of confidence that
  /// the data entered or overwritten is correct.
  /// Especially in the case of automatic operation by AI,
  /// the AI's confidence level is entered here.
  /// In the case of human operation, 1.0 is always entered.
  Cause({
    this.serial,
    this.chainParentSerial,
    required this.who,
    required this.when,
    required this.what,
    required this.why,
    required this.from,
    this.context,
    this.confidenceScore = 1.0,
  });

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory Cause.fromDict(Map<String, dynamic> src) {
    return Cause(
      serial: src["serial"],
      chainParentSerial: src["chainParentSerial"],
      who: Actor.fromDict(src["who"]),
      when: TemporalTrace.fromDict(src["when"]),
      what: src["what"],
      why: src["why"],
      from: src["from"],
      context: src["context"] != null
          ? src["context"] as Map<String, dynamic>
          : null,
      confidenceScore: src["confidenceScore"],
    );
  }

  @override
  CloneableFile clone() {
    return Cause.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "serial": serial,
      "chainParentSerial": chainParentSerial,
      "who": who.toDict(),
      "when": when.toDict(),
      "what": what,
      "why": why,
      "from": from,
      "context": UtilCopy.jsonableDeepCopy(context),
      "confidenceScore": confidenceScore,
    };
  }
}
