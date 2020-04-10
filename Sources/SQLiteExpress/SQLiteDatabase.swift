//
//  SQLiteDatabase.swift
//  SQLiteExpress
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

import Foundation
import SQLite3


/// `SQLiteDatabase` represents a database connection to either a file-based database or a
/// in-memory database.
public class  SQLiteDatabase {
  
  public struct OpenOptions: OptionSet {
    public static let readOnly = OpenOptions(rawValue: SQLITE_OPEN_READONLY)
    public static let readWrite = OpenOptions(rawValue: SQLITE_OPEN_READWRITE)
    public static let create = OpenOptions(rawValue: SQLITE_OPEN_CREATE)
    public static let noMutex = OpenOptions(rawValue: SQLITE_OPEN_NOMUTEX)
    public static let fullMutex = OpenOptions(rawValue: SQLITE_OPEN_FULLMUTEX)
    public static let sharedCache = OpenOptions(rawValue: SQLITE_OPEN_SHAREDCACHE)
    public static let privateCache = OpenOptions(rawValue: SQLITE_OPEN_PRIVATECACHE)
    public static let protectionComplete = OpenOptions(rawValue:
                                             SQLITE_OPEN_FILEPROTECTION_COMPLETE)
    public static let protectionCompleteUnlessOpen = OpenOptions(rawValue:
                                                     SQLITE_OPEN_FILEPROTECTION_COMPLETEUNLESSOPEN)
    public static let protectionCompleteUntilFirstUserAuth = OpenOptions(rawValue:
                                   SQLITE_OPEN_FILEPROTECTION_COMPLETEUNTILFIRSTUSERAUTHENTICATION)
    public static let protectionNone = OpenOptions(rawValue: SQLITE_OPEN_FILEPROTECTION_NONE)
    public static let `default`:  OpenOptions = [.readWrite, .create]
    public static let all: OpenOptions = [.readOnly, .readWrite, .create, .noMutex, .fullMutex,
                                          .sharedCache, .privateCache]
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
  }
  
  /// Returns the version string of the SQLite3 library that is used by SQLiteExpress
  public static var version: String? {
    guard let cstr = sqlite3_libversion() else {
      return nil
    }
    return String(cString: cstr)
  }
  
  /// Returns the version string of the SQLite3 library that is used by SQLiteExpress
  public static var versionNumber: Int {
    return Int(sqlite3_libversion_number())
  }
  
  /// The underlying database connection.
  private var db: OpaquePointer?
  
  /// Open database located at file path `path`, or create an in-memory database if `path` is
  /// not provided. `options` define how the database will be opened.
  public init(path: String? = ":memory:",
              options: OpenOptions = .default,
              extendedErrors: Bool = false) throws {
    var db: OpaquePointer?
    let res = sqlite3_open_v2(path, &db, options.rawValue, nil)
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
    self.db = db
    sqlite3_extended_result_codes(db, extendedErrors ? 1 : 0)
  }
  
  deinit {
    sqlite3_close(self.db)
  }
  
  /// Close database.
  public func close() throws {
    let res = sqlite3_close_v2(self.db)
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
    self.db = nil
  }
  
  /// Prepare the given SQL statement.
  public func prepare(sql: String) throws -> SQLiteStatement {
    guard self.db != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    var stmt: OpaquePointer?
    let res = sqlite3_prepare_v2(self.db, sql, -1, &stmt, nil)
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
    return SQLiteStatement(stmt)
  }
  
  /// The `rowid` of the last row inserted.
  public var lastRowId: Int64 {
    return sqlite3_last_insert_rowid(self.db)
  }
  
  /// The number of rows changed by the last `INSERT`, `UPDATE`, or `DELETE` statement.
  public var lastChanges: Int {
    return Int(sqlite3_changes(self.db))
  }
  
  /// The number of rows changed via `INSERT`, `UPDATE`, or `DELETE` statements since the
  /// database was opened.
  public var totalChanges: Int {
    return Int(sqlite3_total_changes(self.db))
  }
}
