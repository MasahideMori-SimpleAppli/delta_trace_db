## 0.0.20

* When executing a query, users can now specify which queries are explicitly disallowed via optional arguments.

## 0.0.19

* The README has been tweaked.

## 0.0.18

* Fixed a bug where specifying an endBefore in a search query would result in unexpected behavior if user accidentally specified an offset or startAfter, which are not actually required.

## 0.0.17

* The speed test code was out of date so I updated it.
* The new test stores dates and times in the more commonly used ISO 8601 format, which means the amount of data increases and the test takes longer.

## 0.0.16

* Improved type safety when using QueryBuilder and RawQueryBuilder. The conformToTemplate method now takes a Map as an argument.

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
