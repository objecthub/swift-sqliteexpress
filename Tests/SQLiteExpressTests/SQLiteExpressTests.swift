//
//  SQLiteExpressTests.swift
//  SQLiteExpressTests
//
//  Created by Matthias Zenger on 04/04/2020.
//  Copyright © 2020 Google LLC.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import SQLiteExpress

class SQLiteExpressTests: XCTestCase {

  func testBasics() throws {
    let db = try SQLiteDatabase(extendedErrors: true)
    let stmt0 = try db.prepare(sql: "SELECT 10+7 as First, \"Zürich\" as Second;")
    XCTAssertFalse(try stmt0.step())
    XCTAssertEqual(stmt0.columnCount, 2)
    XCTAssertEqual(try stmt0.name(ofColumn: 0), "First")
    XCTAssertEqual(try stmt0.type(ofColumn: 0), .integer)
    XCTAssertEqual(try stmt0.name(ofColumn: 1), "Second")
    XCTAssertEqual(try stmt0.type(ofColumn: 1), .text)
    XCTAssertEqual(try stmt0.int(atColumn: 0), 17)
    XCTAssertEqual(try stmt0.text(atColumn: 1), "Zürich")
    XCTAssertTrue(try stmt0.step())
  }
  
  func testDatabaseBasics() throws {
    let db = try SQLiteDatabase(extendedErrors: true)
    let stmt0 = try db.prepare(sql: """
        CREATE TABLE Contacts (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT
        );
      """)
    XCTAssertTrue(try stmt0.step())
    stmt0.finalize()
    XCTAssertNil(try? stmt0.step())
    let stmt1 = try db.prepare(sql: """
        INSERT INTO Contacts VALUES (?, ?, ?, ?);
      """)
    try stmt1.bind(integer: 1000, toParam: 1)
    try stmt1.bind(text: "Donald Trump", toParam: 2)
    try stmt1.bind(text: "donald@white-house.gov", toParam: 3)
    try stmt1.bind(text: "+1 101-123-456", toParam: 4)
    XCTAssertTrue(try stmt1.step())
    try stmt1.bind(integer: 1001, toParam: 1)
    try stmt1.bind(text: "Mike Pence", toParam: 2)
    try stmt1.bind(text: "mike@white-house.gov", toParam: 3)
    try stmt1.bind(text: "+1 101-123-456", toParam: 4)
    XCTAssertTrue(try stmt1.step())
    try stmt1.bind(integer: 1002, toParam: 1)
    try stmt1.bind(text: "Mark Meadows", toParam: 2)
    try stmt1.bindNull(toParam: 3)
    try stmt1.bind(text: "+1 101-123-456", toParam: 4)
    XCTAssertNil(try? stmt1.step())
    stmt1.reset()
    try stmt1.bind(integer: 1002, toParam: 1)
    try stmt1.bind(text: "Mark Meadows", toParam: 2)
    try stmt1.bind(text: "mark@white-house.gov", toParam: 3)
    try stmt1.bindNull(toParam: 4)
    XCTAssertTrue(try stmt1.step())
    stmt1.finalize()
    let stmt2 = try db.prepare(sql: """
      SELECT COUNT(DISTINCT phone) FROM Contacts;
    """)
    XCTAssertFalse(try stmt2.step())
    XCTAssertEqual(stmt2.columnCount, 1)
    XCTAssertEqual(try stmt2.int(atColumn: 0), 1)
    XCTAssertTrue(try stmt2.step())
    stmt2.finalize()
    let stmt3 = try db.prepare(sql: """
      SELECT name, email FROM Contacts;
    """)
    XCTAssertFalse(try stmt3.step())
    XCTAssertEqual(stmt3.columnCount, 2)
    XCTAssertEqual(try stmt3.name(ofColumn: 0), "name")
    XCTAssertEqual(try stmt3.type(ofColumn: 0), .text)
    XCTAssertEqual(try stmt3.name(ofColumn: 1), "email")
    XCTAssertEqual(try stmt3.type(ofColumn: 1), .text)
    XCTAssertEqual(try stmt3.text(atColumn: 0), "Donald Trump")
    XCTAssertEqual(try stmt3.text(atColumn: 1), "donald@white-house.gov")
    XCTAssertFalse(try stmt3.step())
    XCTAssertEqual(try stmt3.text(atColumn: 0), "Mike Pence")
    XCTAssertEqual(try stmt3.text(atColumn: 1), "mike@white-house.gov")
    XCTAssertFalse(try stmt3.step())
    XCTAssertEqual(try stmt3.text(atColumn: 0), "Mark Meadows")
    XCTAssertEqual(try stmt3.text(atColumn: 1), "mark@white-house.gov")
    XCTAssertTrue(try stmt3.step())
    stmt3.finalize()
  }
}
