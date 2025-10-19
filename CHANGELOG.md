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
