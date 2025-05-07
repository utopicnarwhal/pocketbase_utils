# Changelog

## 0.1.3

* Remove "username" field from the "system" fields of the Auth collection.
* Making "email" Auth collection system field required only when the collection has both "emailVisibility" and "email" fields set to "required".
* Make boolean fields to be nullable only when "hidden" instead of "required".
* Loosen the "analyzer" dependency

## 0.1.2

* Add support for `geoPoint` field type.

## 0.1.1

* Add support for collection fields that are not in camel case by default
* Improve enums to support the non camel case values

## 0.1.0

* Migrate the codebase to support only collection schema file from PocketBase version > 0.23.0
* Upgrade dependencies

## 0.0.7

* Added custom json convertion methods for the `date` type of field which allows to handle a case when the pocketbase backend returns an empty string when the `DateTime` value is empty.
* Upgrade dependencies

## 0.0.6

* Determine if a field has an `int` or `double` type
* min/max values are added to the class definition as `static` `const` values.

## 0.0.5

* `copyWith` method is added to the gererated Records
* Take the values from `toJSON` when running `takeDiff` or `forCreateRequest` of a Record

## 0.0.4

* Fix select field enums when an option isn't complient to variable name

## 0.0.3

* `AuthRecord` extends from `BaseRecord`
* The `BaseRecord` extends [`Equatable`](https://pub.dev/packages/equatable)
* Added `_takeDiff` method to the generated record class to get a Map of differences
* Added `_forCreateRequestMethod` method to the generated record class to get a Map of values for the "Create" request
* Added `EmptyDateTime` to be able to diff it with null in `_takeDiff`
* Generate options of the `select` type of the field

## 0.0.2

* Add `fromRecordModel` factory to the generated class
* Read `collectionId` and `collectionName` from the RecordModel
* Set to read `json` field type as `dynamic`

## 0.0.1

* Create typesafe models from `pb_schema.json`
