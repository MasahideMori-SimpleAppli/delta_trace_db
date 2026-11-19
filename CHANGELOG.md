## 0.5.0 (2026-11-20)

* Updated `simple_portable_numeric` to 0.1.0.
  The rounding mode `up` (away from zero) can be used in `aggregate` queries,
  and the new methods such as `PortableDecimal.parseLenient`, `pow`, `toBigInt` and `PortableRational.toDecimalExact` are available.
* `clearAdd` and `clearAddCsv`: `updateCount` is now the number of cleared items plus the number of
  added items (it was the number of cleared items only). Previously, these queries failed with
  `mustAffectAtLeastOne` (the default) when the collection was empty, even though the items were added.
  A query that adds no items to an empty collection still fails.
* Grouping by date-time in `aggregate` queries (`AggregateGroupKey.unit`) and sorting with `datetime_`
  are faster.
* `datetime_` values without a time zone are no longer converted to the local time of the running
  machine in comparisons, sorts and date-time grouping, so the results no longer depend on its time zone.
  Previously, on a machine with daylight saving time, a time skipped by it (e.g. 02:30 on the day the
  clocks go forward) was shifted by an hour, and the results could differ from the Python version.
  A `DateTime` made in local time by the application (including one restored with `fromDict`) is still
  subject to this shift by Dart itself, so use a UTC `DateTime` for such times.
* `aggregate` query: aggregations with `field` are as fast as in 0.3.0 again. Since 0.4.0, they were
  calculated in the same way as `fields` (products of fields), which was slower.

## 0.4.0 (2026-11-17)

* Added the `addCsv` and `clearAddCsv` query types. They take CSV text (`csvText`) and add its rows
  to the collection as items of `{column name: cell text}` (all values are strings). `clearAddCsv`
  clears the collection first, in the same way as `clearAdd`.
  If the CSV is invalid, the query fails without changing anything, and `errorMessage` shows the kind
  of error and the line number (e.g. `CsvFormatError(columnCount, line 3)`).
* Added `QueryBuilder.addCsv` and `QueryBuilder.clearAddCsv` to the query builder.
* Added `UtilCsv`, `CsvFormatError` and `EnumCsvErrorKind`, which convert and check CSV text with the
  same rules as the queries above.
* `Query`: added `csvText`, `joins` and `groupBy`, and updated the version to 9. Queries made with earlier versions can still be read.
  Queries that use the new types cannot be read by earlier versions.
  Earlier versions ignore `joins` and `groupBy` without an error and return the aggregation of all
  matched items, so send queries that use them only to version 0.4.0 or later (e.g. on the server).
* `aggregate` query: added joins, groups and products of fields.
  * `joins`: attaches the matching item of another collection to each item under an alias
    (`AggregateJoin`), so its fields can be used as `alias.field` in the query node, the group keys and
    the aggregations. Exactly one item must match; otherwise the query fails.
    The joined collections also require the search or searchOne permission.
  * `groupBy`: calculates the aggregations per group (`AggregateGroupKey`). Date-time values can be
    grouped by day, week, month, quarter or year (`EnumAggregateGroupUnit`) in a given time zone, with
    a configurable first day of the week and first month of the year. The result contains one map per
    group, which can be sorted with `sortObj`.
  * `Aggregation`: added `fields` to aggregate the product of several fields, and updated the version to 2.
  * Queries without these options return the same results as before.
* `aggregate` query: error messages no longer contain the values of items, so that data is not exposed
  through them (e.g. `Cannot convert the value of field 'qty' to decimal_.`).

## 0.3.0 (2026-11-15)

This version changes the behavior of some conversions so that the Dart and Python versions always
return the same results.

* `SingleSort`: a value that cannot be converted with `vType` is now treated as null for every type
  (it moves to the end in ascending order), instead of making the query fail.
  With `int_`, `floatStrict_` and `floatEpsilon12_`, `bool`, `NaN` and (for `int_`) infinite values are
  treated as conversion failures.
* `MultiSort` itself is unchanged (its version is still 1). The `SingleSort` changes in this version apply
  to each `SingleSort` in a `MultiSort`, and `naiveUtcOffsetMinutes` (added below) is set on each `SingleSort`.
* Strings are converted to numbers with the same rules as Dart's `int.parse` / `double.parse`:
  surrounding whitespace is ignored, `int_` accepts decimal digits and `0x` hexadecimal numbers
  (64-bit), and floating-point types accept forms such as `"1e3"`, `".5"`, `"Infinity"` and `"NaN"`.
  `"1_000"`, `"inf"`, `"nan"` and non-ASCII digits are not converted.
* `datetime_` now accepts only valid ISO 8601 date-times. Out-of-range values (e.g. month 13,
  February 30, hour 24, minute 60), a lowercase `z`, mixed basic / extended formats, week dates and
  ordinal dates are conversion failures (previously the Dart version silently carried over values such as
  month 13 to the next year).
* `datetime_` no longer compares a timezone-aware value with a naive value.
  Comparison nodes return false (including `FieldNotEquals`), and `SingleSort` treats the naive value as null
  when it is compared with an aware one. Previously the Dart version interpreted naive values in the local
  timezone of the running machine.
* Added `naiveUtcOffsetMinutes` to the comparison nodes (`FieldEquals`, `FieldNotEquals`, `FieldGreaterThan`, `FieldLessThan`,
  `FieldGreaterThanOrEqual`, `FieldLessThanOrEqual`) and `SingleSort`. With `datetime_`, naive date-times are
  interpreted as times at UTC + this many minutes (e.g. 540 for UTC+9), so aware and naive values can be compared.
  A value of -1440 or less, or 1440 or more, throws `ArgumentError`.
  Queries that use it are read by older versions without an error but with the option ignored.
* Comparison node version is now 3, and `SingleSort` version is now 6 (added `naiveUtcOffsetMinutes`).

## 0.2.0 (2026-11-14)

* Added `decimal_` and `rational_` to `EnumValueType`.
  Values are converted with the `simple_portable_numeric` package and compared by value,
  so the results are identical to the Python version
  (e.g. `"1.50"` equals `"1.5"`, and digits beyond double precision are not lost).
  Only `String`, `PortableDecimal` and `PortableRational` are converted.
  Numbers such as `int` and `double` are treated as conversion failures,
  because their exactness cannot be guaranteed. This also applies to the query value,
  so a comparison with an `int` value such as `FieldGreaterThan("v", 11, vType: EnumValueType.decimal_)`
  is always false. Use `"11"` instead.
* The comparison nodes (`FieldEquals`, `FieldNotEquals`, `FieldGreaterThan`, `FieldLessThan`,
  `FieldGreaterThanOrEqual`, `FieldLessThanOrEqual`) set `vType` automatically when
  a `PortableDecimal` or `PortableRational` is passed as the value, and save it as a String.
* `SingleSort` (and therefore `MultiSort`) supports `decimal_` and `rational_`.
  Values that cannot be converted are treated as null.
* Added `simple_portable_numeric` to the dependencies.
  `PortableDecimal`, `PortableRational` and `EnumRoundingMode` are re-exported from this package.
* Queries using the new types cannot be read by older versions.
* Added the `aggregate` query type (`QueryBuilder.aggregate` / `RawQueryBuilder.aggregate`).
  It calculates `count_`, `sum_`, `min_`, `max_` and `mean_` (`EnumAggregateType`) for the items
  that match an optional query node, and returns the results as a single map in `result`.
  Each `Aggregation` chooses the calculation type with `vType`:
  `floatStrict_` (double), `decimal_` or `rational_` (exact, results are strings).
  `mean_` with `decimal_` requires `scale` and `rounding`.
  Null and missing values are excluded, and values that cannot be converted make the query fail.
  The results are identical between the Dart and Python versions
  (floating-point sums use simple left-to-right addition in both).
  Security: treat the `aggregate` permission as equivalent to read (`search`) access,
  because the contents can be discovered through aggregations (e.g. repeating `count_` with
  `FieldStartsWith` while extending the prefix one character at a time), and `min_` / `max_`
  return field values directly.
* `Query` version is now 8 (added `aggregations`).

## 0.1.6 (2026-04-30)

* Fixed a type error in `Cause.fromDict` where `confidenceScore` could be deserialized
  as `int` instead of `double` in certain environments (e.g. iOS app mode on macOS).
  Added `_d()` helper and applied it to the `confidenceScore` assignment.

## 0.1.5 (2026-04-12)

* Delete the old test files.

## 0.1.4 (2026-04-12)

* Added `stringIgnoreCase_` to `EnumValueType`. When this type is used, string comparison is performed after converting both values to lowercase.
* Fixed test file names: `verson_up_test.dart` (typo) → `version_up_test.dart`, `transaction_test2.dart` → `transaction2_test.dart`. These are test-only changes with no impact on library behavior.
* Fixed a test assertion in `transaction2_test.dart` that used `MapEquality` for nested map comparison; replaced with `DeepCollectionEquality`. This is a test-only fix with no impact on library behavior.

## 0.1.3

* Added information about corporate/enterprise support in the README.

## 0.1.2

* Improve hash comparison accuracy for `Actor` class by updating internal dependencies. 
* Update hash calculation for `Permission` class (no significant behavior change).

## 0.1.1

* Merge queries now allow nested values in relationKey and sourceKeys, and you can access them using dot notation.

## 0.1.0

* A new query type, Merge, has been added.
* The priority of the mustAffectAtLeastOne error and other errors has been changed so that other errors take priority.
* Added getSerialNum method to Collection class.

## 0.0.40

* Removed unnecessary generics from TransactionQueryResult.

## 0.0.39

* The following optional parameters have been added to the Actor class: name, email, createdAt, updatedAt, lastAccess, lastAccessDay, operationInDay, and deviceIds.

## 0.0.38

* Updated readme.
* Updated example.

## 0.0.37

* Refactoring was performed.
* Documentation additions and corrections have been made.
* The argument of FieldNotIn has been changed from Iterable to list.
* The return type of RawQueryBuilder's setOffset, setStartAfter, setEndBefore, and setLimit has been corrected to RawQueryBuilder.

## 0.0.36

* Refactoring was performed.
* The Actor class has had roles and permissions removed, replaced by the simpler collectionPermissions.
* Fixed an issue where hash calculation for collectionPermissions was not done.

## 0.0.35

* Added a description about time zone handling to the README.
* Added setOffset, setStartAfter, setEndBefore, setLimit method to QueryBuilder and RawQueryBuilder.

## 0.0.34

* In search queries, sortObj is no longer required when using offset, startAfter, or endBefore. If not specified, the queries will be processed in the order they were added to the database.
* The getAll query now supports offset, startAfter, endBefore, and limit, making it easier to implement paging within a collection.
* Improved QueryBuilder and RawQueryBuilder descriptions.

## 0.0.33

* The searchOne query has been added, which works quickly when searching for only one item. 
* The removeCollection query has been added.
* Fixed a bug in the clearAdd function where only clearing would be performed if the serial key was invalid. This change may affect past queries, so if any of your failing queries(version less than 6) have this, use a clear query to fix it.
* Fixed a bug where the resetSerial parameter was disabled in RawQueryBuilder.
* Updated readme and test.

## 0.0.32

* Security fixes. This is important, so please update if you are running an older version.
* Logging on the app has been changed to be handled using the [logging](https://pub.dev/packages/logging) package, so if you want to get error logs, please refer to the logging package.
* Added findCollection and removeCollection method to DeltaTraceDataBase class.
* The name option has been added to the addListener and removeListener methods of the DeltaTraceDataBase and Collection classes.
* When executing listeners for the DeltaTraceDataBase class and Collection class, if an error occurs in the callback, processing will stop there. This has been changed so that subsequent processing can continue even if an error occurs during the callback.
* Fixed a bug that caused transaction queries to not work correctly under certain conditions.
* The collectionToDict method of the deltaTraceDatabase class has been modified to return null if a non-existent collection is specified.
* Added explanatory text for QueryBuilder and RawQueryBuilder.

## 0.0.31

* The QueryResult class now has a target parameter, which is set to the target at the time the query was issued, making debugging a bit easier.
* The documentation for the QueryResult class has been improved.

## 0.0.30

* Added a note to the Readme.
* Added automated tests.

## 0.0.29

* Fixed a bug where Actor class comparisons ignored element order.

## 0.0.28

* Fixed an issue where internal class version number changes were missing.
* Automated tests have been added.

## 0.0.27

* The returnData flag is now available for Add and ClearAdd queries.
* The returnData flag for various queries has been changed to an optional argument.
* The Actor class now has a collectionPermissions, which uses a dedicated Permissions type.
* As a result, the method for setting permissions in the DeltaTraceDatabase class has been changed from an Enum to a dedicated type.

## 0.0.26

* Several methods in the DeltaTraceDatabase class now have an allows parameter to grant permission
  to execute queries.
* When sorting, you can now convert to a specified type.
* The code documentation has been improved.

## 0.0.25

* Updated document in code.

## 0.0.24

* Added reset serial option to the clear and clearAdd queries.

## 0.0.23

* Bugfix of speed test.

## 0.0.22

* The serialKey parameter has been added to Query(add, clearAdd).

## 0.0.21

* Added UtilQuery class.

## 0.0.20

* When executing a query, users can now specify which queries are explicitly disallowed via optional
  arguments.

## 0.0.19

* The README has been tweaked.

## 0.0.18

* Fixed a bug where specifying an endBefore in a search query would result in unexpected behavior if
  user accidentally specified an offset or startAfter, which are not actually required.

## 0.0.17

* The speed test code was out of date so I updated it.
* The new test stores dates and times in the more commonly used ISO 8601 format, which means the
  amount of data increases and the test takes longer.

## 0.0.16

* Improved type safety when using QueryBuilder and RawQueryBuilder. The conformToTemplate method now
  takes a Map as an argument.

## 0.0.15

* Added missing mustAffectAtLeastOne to RawQueryBuilder.
* Improved documentation text for QueryBuilder and RawQueryBuilder.

## 0.0.14

+ Changed the initial offset value to null when initializing a QueryBuilder.

## 0.0.13

* Fixed a bug that caused callbacks to be lost when a transaction failed.
* When processing a transaction, the notification functionality for each collection is now processed
  on a per-transaction basis.
* QueryResult now has a type variable.
* Added collectionFromDictKeepListener to DeltaTraceDatabase.
* Other minor changes.

## 0.0.12

* Added raw variables to DeltaTraceDatabase.
* Refactoring has been performed.

## 0.0.11

* Fixed a bug that prevented multi-sort objects from being restored when restoring query objects.

## 0.0.10

* I did some refactoring.

## 0.0.9

* The isNoErrors variable of QueryResult and TransactionQueryResult has been changed to the
  isSuccess variable.
* Fixed README.

## 0.0.8

* The TransactionQuery class and TransactionQueryResult class have been added.
* The DeltaTraceDatabase class now has an executeQueryObject method that can execute Query,
  TransactionQuery, or Map.
* The executeTransactionQuery method has now been added to the DeltaTraceDatabase class.
* The Query class now has a new parameter, mustAffectAtLeastOne. This value is initially set to true
  so that the DB behaves differently than before.
* The description of the QueryResult class has been adjusted to match the new specifications.
* For add queries, the return value updateCount has been changed to describe the number of objects
  appended.
* deleteOne has been added to the query types.
* Runtime errors in renameField are now checked before execution. This prevents the possibility of
  partial updates.

## 0.0.7

* I performed a refactoring.

## 0.0.6

* Added RawQueryBuilder class, which is useful for certain purposes.
* Several query nodes now support automatic DateTime conversion, improving search speed when
  comparing DateTime values.
* Added operation instructions to the README.

## 0.0.5

* The SingleSort class has been improved to allow sorting on null and Boolean values.

## 0.0.4

* A listener has been added that will call back when the DB state changes.

## 0.0.3

* Fixed an issue where a dependency on Flutter was still present.

## 0.0.2

* This package has been changed to a Dart package and no longer depends on Flutter.

## 0.0.1

* initial release.
