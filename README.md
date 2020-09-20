#  SQLiteExpress

[![Platforms: macOS, iOS](https://img.shields.io/badge/Platforms-macOS,%20iOS-blue.svg?style=flat)](https://developer.apple.com/osx/) [![Language: Swift 5.3](https://img.shields.io/badge/Language-Swift%205.3-green.svg?style=flat)](https://developer.apple.com/swift/) [![IDE: Xcode 12.0](https://img.shields.io/badge/IDE-Xcode%2012.0-orange.svg?style=flat)](https://developer.apple.com/xcode/) [![Package managers: SwiftPM, Carthage](https://img.shields.io/badge/Package%20managers-SwiftPM,%20Carthage-8E64B0.svg?style=flat)](https://github.com/Carthage/Carthage) [![License: Apache](http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](https://raw.githubusercontent.com/objecthub/swift-sqliteexpress/master/LICENSE)

## Overview

[_SQLiteExpress_](https://github.com/objecthub/swift-sqliteexpress) is a Swift library implementing a lightweight wrapper for the C API of [SQLite3](https://www.sqlite.org/) on macOS and iOS. _SQLiteExpress_ provides

- an object-oriented data model,
- a clear separation of errors, expressed as exceptions, from results and side-effects, and
- uses Swift programming paradigms throughout its implementation.

This is done without changing the programming protocol of the [C API of SQLite3](https://www.sqlite.org/c3ref/intro.html). _SQLiteEpress_ does not provide any help in crafting SQL statements, e.g. in a type-safe manner. If this functionality is needed, other SQLite wrappers are more suitable.

## Usage example

The following code snippet gives a flavor of how _SQLiteExpress_ is used. The code snippet does the following things:

1. It creates a new in-memory database
2. It creates a new table in the database
3. It enters data into the new table
4. It queries the new table for some data

```swift
// Create a new in-memory database `db` and require extended errors to be thrown.
let db = try SQLiteDatabase(extendedErrors: true)

// Create a new table in `db`.
let stmt0 = try db.prepare(sql: """
    CREATE TABLE Contacts (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      phone TEXT
    );
  """)
try stmt0.step()
stmt0.finalize()

// Enter two rows into the new table.
let stmt1 = try db.prepare(sql: """
    INSERT INTO Contacts VALUES (?, ?, ?, ?);
  """)
try stmt1.bind(integer: 1000, toParam: 1)
try stmt1.bind(text: "Mickey Mouse", toParam: 2)
try stmt1.bind(text: "mickey@disney.net", toParam: 3)
try stmt1.bind(text: "+1 101-123-456", toParam: 4)
try stmt1.step()
try stmt1.bind(integer: 1001, toParam: 1)
try stmt1.bind(text: "Donald Duck", toParam: 2)
try stmt1.bind(text: "donald@disney.net", toParam: 3)
try stmt1.bind(text: "+1 101-123-456", toParam: 4)
try stmt1.step()
stmt1.finalize()

// Cound the number of distinct phone numbers.
let stmt2 = try db.prepare(sql: """
    SELECT COUNT(DISTINCT phone) FROM Contacts;
  """)
try stmt2.step()
let phoneNumbers = try stmt2.int(atColumn: 0)
Swift.print("Number of distinct phone numbers: \(phoneNumbers)")
stmt2.finalize()

// Show all names and email addresses from the `Contacts` table.
let stmt3 = try db.prepare(sql: """
    SELECT name, email FROM Contacts;
  """)
Swift.print("Entries in table:")
while try !stmt3.step() {
 Swift.print("\(try stmt3.text(atColumn: 0)!), \(try stmt3.text(atColumn: 1)!)")
}
stmt3.finalize()
```

When executed, the code prints out the following lines:

```
Number of distinct phone numbers: 1
Entries in table:
Mickey Mouse, mickey@disney.net
Donald Duck, donald@disney.net
```

## Requirements

The following technologies are needed to build the components of the _Swift SQLiteExpress_ framework:

- [Xcode 12.0](https://developer.apple.com/xcode/)
- [Swift 5.3](https://developer.apple.com/swift/)
- [Swift Package Manager](https://swift.org/package-manager/)

## Copyright

Author: Matthias Zenger (<matthias@objecthub.net>)  
Copyright © 2020 Google LLC.  
_Please note: This is not an official Google product._
