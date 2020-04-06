//
//  SQLiteStatement.swift
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


public class SQLiteStatement {
  
  private static let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
  private static let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  /// Formatter for reading and writing dates.
  public static var dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      return formatter
  }()
  
  private var stmt: OpaquePointer?
  
  internal init(_ stmt: OpaquePointer?) {
    self.stmt = stmt
  }
  
  deinit {
    sqlite3_finalize(self.stmt)
  }
  
  /// Returns true if the result is done
  @discardableResult public func step() throws -> Bool {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    let res = sqlite3_step(self.stmt)
    switch res {
      case SQLITE_DONE:
        sqlite3_reset(self.stmt)
        return true
      case SQLITE_ROW:
        return false
      default:
        throw SQLiteError(res)
    }
  }
  
  public func reset() {
    guard self.stmt != nil else {
      return
    }
    sqlite3_reset(self.stmt)
  }
  
  public func finalize() {
    guard self.stmt != nil else {
      return
    }
    sqlite3_finalize(self.stmt)
    self.stmt = nil
  }
  
  public var columnCount: Int {
    guard self.stmt != nil else {
      return 0
    }
    return Int(sqlite3_column_count(self.stmt))
  }
  
  public func name(ofColumn col: Int) throws -> String? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let cstr = sqlite3_column_name(self.stmt, Int32(col)) else {
      return nil
    }
    return String(cString: cstr)
  }
  
  public func databaseName(ofColumn col: Int) throws -> String? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let cstr = sqlite3_column_database_name(self.stmt, Int32(col)) else {
      return nil
    }
    return String(cString: cstr)
  }
  
  public func tableName(ofColumn col: Int) throws -> String? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let cstr = sqlite3_column_table_name(self.stmt, Int32(col)) else {
      return nil
    }
    return String(cString: cstr)
  }
  
  public func originalName(ofColumn col: Int) throws -> String? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let cstr = sqlite3_column_origin_name(self.stmt, Int32(col)) else {
      return nil
    }
    return String(cString: cstr)
  }
  
  public func type(ofColumn col: Int) throws -> SQLiteType? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    return SQLiteType(rawValue: sqlite3_column_type(self.stmt, Int32(col)))
  }
  
  public func declaredType(ofColumn col: Int) throws -> String? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let cstr = sqlite3_column_decltype(self.stmt, Int32(col)) else {
      return nil
    }
    return String(cString: cstr)
  }
  
  public func int(atColumn col: Int) throws -> Int64 {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    return sqlite3_column_int64(self.stmt, Int32(col))
  }
  
  public func float(atColumn col: Int) throws -> Double {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    return sqlite3_column_double(self.stmt, Int32(col))
  }
  
  public func text(atColumn col: Int) throws -> String? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let cstr = sqlite3_column_text(self.stmt, Int32(col)) else {
      return nil
    }
    return String(cString: cstr)
  }
  
  public func blob(atColumn col: Int) throws -> Data? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let blob = sqlite3_column_blob(self.stmt, Int32(col)) else {
      return nil
    }
    return Data(bytes: blob, count: Int(sqlite3_column_bytes(self.stmt, Int32(col))))
  }
  
  public func date(atColumn col: Int) throws -> Date? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    guard let cstr = sqlite3_column_text(self.stmt, Int32(col)) else {
      return nil
    }
    guard let date = Self.dateFormatter.date(from: String(cString: cstr)) else {
      return nil
    }
    return date
  }
  
  public func isNull(atColumn col: Int) throws -> Bool {
    guard self.stmt != nil else {
      throw SQLiteError.misuse
    }
    return sqlite3_column_type(self.stmt, Int32(col)) == SQLITE_NULL
  }
  
  public var paramCount: Int {
    guard self.stmt != nil else {
      return 0
    }
    return Int(sqlite3_bind_parameter_count(self.stmt))
  }
  
  public func paramIndex(_ name: String) throws -> Int {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    return Int(sqlite3_bind_parameter_index(self.stmt, name.cString(using: .utf8)))
  }
  
  public func paramName(_ idx: Int) throws -> String? {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    return String(cString: sqlite3_bind_parameter_name(self.stmt, Int32(idx)))
  }
  
  public func bind(integer x: Int64, toParam idx: Int) throws {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    let res = sqlite3_bind_int64(self.stmt, Int32(idx), x)
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
  }
  
  public func bind(float x: Double, toParam idx: Int) throws {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    let res = sqlite3_bind_double(self.stmt, Int32(idx), x)
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
  }
  
  public func bind(text x: String, toParam idx: Int) throws {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    let res = sqlite3_bind_text(self.stmt,
                                Int32(idx),
                                x.cString(using: .utf8),
                                -1,
                                Self.SQLITE_TRANSIENT)
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
  }
  
  public func bind(blob x: Data, toParam idx: Int) throws {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    let res = x.withUnsafeBytes { bufferPointer -> Int32 in
      sqlite3_bind_blob(self.stmt,
                        Int32(idx),
                        bufferPointer.baseAddress,
                        Int32(x.count),
                        Self.SQLITE_TRANSIENT)
    }
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
  }
  
  public func bind(date x: Date, toParam idx: Int) throws {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    let res = sqlite3_bind_text(self.stmt,
                                Int32(idx),
                                Self.dateFormatter.string(from: x).cString(using: .utf8),
                                -1,
                                Self.SQLITE_TRANSIENT)
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
  }
  
  public func bindNull(toParam idx: Int) throws {
    guard self.stmt != nil else {
      throw SQLiteError(SQLITE_MISUSE)
    }
    let res = sqlite3_bind_null(self.stmt, Int32(idx))
    guard res == SQLITE_OK else {
      throw SQLiteError(res)
    }
  }
}
