## 0.0.9

* The isNoErrors variable of QueryResult and TransactionQueryResult has been changed to the isSuccess variable.
* Fixed README.

## 0.0.8

* The TransactionQuery class and TransactionQueryResult class have been added.
* The DeltaTraceDatabase class now has an executeQueryObject method that can execute Query, TransactionQuery, or Map.
* The executeTransactionQuery method has now been added to the DeltaTraceDatabase class.
* The Query class now has a new parameter, mustAffectAtLeastOne. This value is initially set to true so that the DB behaves differently than before.
* The description of the QueryResult class has been adjusted to match the new specifications.
* For add queries, the return value updateCount has been changed to describe the number of objects appended.
* deleteOne has been added to the query types.
* Runtime errors in renameField are now checked before execution. This prevents the possibility of partial updates.

## 0.0.7

* I performed a refactoring.

## 0.0.6

* Added RawQueryBuilder class, which is useful for certain purposes.
* Several query nodes now support automatic DateTime conversion, improving search speed when comparing DateTime values.
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
