//
//  SQLiteError.swift
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


/// `SQLiteError` enumerates all errors that can be thrown by methods of the SQLiteExpress framework.
/// Both primary as well as extended result/error codes from SQLite are supported.
public struct SQLiteError: LocalizedError, Hashable, CustomStringConvertible {

  /// The corresponding error code
  public let errorCode: SQLiteResultCode
  
  /// An optional string describing error details, e.g. the context of the error
  public let errorDetails: String?
  
  /// `SQLiteError` initializer for a given error code.
  public init(_ errorCode: SQLiteResultCode, details: String?) {
    self.errorCode = errorCode
    self.errorDetails = details
  }
  
  /// `SQLiteError` initializer for raw error codes.
  public init(_ rawErrorCode: Int32, details: String?) {
    self.init(SQLiteResultCode(rawErrorCode), details: details)
  }
  
  /// `SQLiteError` initializer for a given error code in a given database.
  public init(_ errorCode: SQLiteResultCode, database: SQLiteDatabase? = nil) {
    self.init(errorCode, details: database?.lastErrorDetails)
  }
  
  /// `SQLiteError` initializer for raw error codes in a given database.
  public init(_ rawErrorCode: Int32, database: SQLiteDatabase? = nil) {
    self.init(SQLiteResultCode(rawErrorCode), details: database?.lastErrorDetails)
  }
  
  /// Returns a localized description of this error as a string.
  public var errorDescription: String? {
    if let details = self.errorDetails {
      return "\(self.errorCode.message): \(details)"
    } else {
      return self.errorCode.message
    }
  }
  
  /// Returns a localized description of this error as a string.
  public var description: String {
    if let message = self.errorDescription {
      return "\(message) (\(self.errorCode))"
    } else {
      return "unknown SQLite3 error (\(self.errorCode))"
    }
  }
  
  public static func == (lhs: SQLiteError, rhs: SQLiteError) -> Bool {
    return lhs.errorCode == rhs.errorCode && lhs.errorDetails == rhs.errorDetails
  }
}

/// `SQLiteResultCode` enumerates all result codes that can be returned by the SQLite3 API.
/// Both primary as well as extended result/error codes from SQLite3 are supported.
public enum SQLiteResultCode: Hashable {
  case ok
  case error
  case `internal`
  case perm
  case abort
  case busy
  case locked
  case noMem
  case readOnly
  case interrupt
  case ioErr
  case corrupt
  case notFound
  case full
  case cantOpen
  case `protocol`
  case empty
  case schema
  case tooBig
  case constraint
  case mismatch
  case misuse
  case noLfs
  case auth
  case format
  case range
  case notADb
  case notice
  case warning
  case row
  case done
  case okLoadPermanently
  case errorMissingCollSeq
  case busyRecovery
  case lockedShardCache
  case readOnlyRecovery
  case ioErrRead
  case corruptVTab
  case cantOpenNotEmpDir
  case constraintCheck
  case noticeRecoverWal
  case warningAutoIndex
  case errorRetry
  case abortRollback
  case busySnapshot
  case lockedVTab
  case readOnlyCantLock
  case ioErrShortRead
  case corruptSequence
  case cantOpenIsDir
  case constraintCommitHook
  case noticeRecoverRollback
  case errorSnapshot
  case readOnlyRollback
  case ioErrWrite
  case cantOpenFullPath
  case constraintForeignKey
  case readOnlyDbMoved
  case ioErrFSync
  case cantOpenConvPath
  case constraintFunction
  case readOnlyCantInit
  case ioErrDirFSync
  case cantOpenDirtyWal
  case constraintNotNull
  case readOnlyDirectory
  case ioErrTruncate
  case constraintPrimaryKey
  case ioErrFStat
  case constraintTrigger
  case ioErrUnlock
  case constraintUnique
  case ioErrRdLock
  case constraintVTab
  case ioErrDelete
  case constraintRowId
  case ioErrBlocked
  case ioErrNoMem
  case ioErrAccess
  case ioErrCheckReservedLock
  case ioErrLock
  case ioErrClose
  case ioErrDirClose
  case ioErrShmOpen
  case ioErrShmSize
  case ioErrShmLock
  case ioErrShmMap
  case ioErrSeek
  case ioErrDeleteNoEnt
  case ioErrMMap
  case ioErrGetTempPath
  case ioErrConvPath
  case unknown(Int32)
  
  /// Initializes an `SQLiteResultCode` from the given raw value `rawValue`.
  internal init(_ rawValue: Int32) {
    switch rawValue {
      case SQLITE_OK:         self = .ok
      case SQLITE_ERROR:      self = .error
      case SQLITE_INTERNAL:   self = .internal
      case SQLITE_PERM:       self = .perm
      case SQLITE_ABORT:      self = .abort
      case SQLITE_BUSY:       self = .busy
      case SQLITE_LOCKED:     self = .locked
      case SQLITE_NOMEM:      self = .noMem
      case SQLITE_READONLY:   self = .readOnly
      case SQLITE_INTERRUPT:  self = .interrupt
      case SQLITE_IOERR:      self = .ioErr
      case SQLITE_CORRUPT:    self = .corrupt
      case SQLITE_NOTFOUND:   self = .notFound
      case SQLITE_FULL:       self = .full
      case SQLITE_CANTOPEN:   self = .cantOpen
      case SQLITE_PROTOCOL:   self = .`protocol`
      case SQLITE_EMPTY:      self = .empty
      case SQLITE_SCHEMA:     self = .schema
      case SQLITE_TOOBIG:     self = .tooBig
      case SQLITE_CONSTRAINT: self = .constraint
      case SQLITE_MISMATCH:   self = .mismatch
      case SQLITE_MISUSE:     self = .misuse
      case SQLITE_NOLFS:      self = .noLfs
      case SQLITE_AUTH:       self = .auth
      case SQLITE_FORMAT:     self = .format
      case SQLITE_RANGE:      self = .range
      case SQLITE_NOTADB:     self = .notADb
      case SQLITE_NOTICE:     self = .notice
      case SQLITE_WARNING:    self = .warning
      case 100:               self = .row
      case 101:               self = .done
      case 256:               self = .okLoadPermanently
      case 257:               self = .errorMissingCollSeq
      case 261:               self = .busyRecovery
      case 262:               self = .lockedShardCache
      case 264:               self = .readOnlyRecovery
      case 266:               self = .ioErrRead
      case 267:               self = .corruptVTab
      case 270:               self = .cantOpenNotEmpDir
      case 275:               self = .constraintCheck
      case 283:               self = .noticeRecoverWal
      case 284:               self = .warningAutoIndex
      case 513:               self = .errorRetry
      case 516:               self = .abortRollback
      case 517:               self = .busySnapshot
      case 518:               self = .lockedVTab
      case 520:               self = .readOnlyCantLock
      case 522:               self = .ioErrShortRead
      case 523:               self = .corruptSequence
      case 526:               self = .cantOpenIsDir
      case 531:               self = .constraintCommitHook
      case 539:               self = .noticeRecoverRollback
      case 769:               self = .errorSnapshot
      case 776:               self = .readOnlyRollback
      case 778:               self = .ioErrWrite
      case 782:               self = .cantOpenFullPath
      case 787:               self = .constraintForeignKey
      case 1032:              self = .readOnlyDbMoved
      case 1034:              self = .ioErrFSync
      case 1038:              self = .cantOpenConvPath
      case 1043:              self = .constraintFunction
      case 1288:              self = .readOnlyCantInit
      case 1290:              self = .ioErrDirFSync
      case 1294:              self = .cantOpenDirtyWal
      case 1299:              self = .constraintNotNull
      case 1544:              self = .readOnlyDirectory
      case 1546:              self = .ioErrTruncate
      case 1555:              self = .constraintPrimaryKey
      case 1802:              self = .ioErrFStat
      case 1811:              self = .constraintTrigger
      case 2058:              self = .ioErrUnlock
      case 2067:              self = .constraintUnique
      case 2314:              self = .ioErrRdLock
      case 2323:              self = .constraintVTab
      case 2570:              self = .ioErrDelete
      case 2579:              self = .constraintRowId
      case 2826:              self = .ioErrBlocked
      case 3082:              self = .ioErrNoMem
      case 3338:              self = .ioErrAccess
      case 3594:              self = .ioErrCheckReservedLock
      case 3850:              self = .ioErrLock
      case 4106:              self = .ioErrClose
      case 4362:              self = .ioErrDirClose
      case 4618:              self = .ioErrShmOpen
      case 4874:              self = .ioErrShmSize
      case 5130:              self = .ioErrShmLock
      case 5386:              self = .ioErrShmMap
      case 5642:              self = .ioErrSeek
      case 5898:              self = .ioErrDeleteNoEnt
      case 6154:              self = .ioErrMMap
      case 6410:              self = .ioErrGetTempPath
      case 6666:              self = .ioErrConvPath
      default:                self = .unknown(rawValue)
    }
  }
  
  /// Returns the raw value for this `SQLiteResultCode` object.
  public var rawValue: Int32 {
    switch self {
      case .ok:                     return SQLITE_OK
      case .error:                  return SQLITE_ERROR
      case .internal:               return SQLITE_INTERNAL
      case .perm:                   return SQLITE_PERM
      case .abort:                  return SQLITE_ABORT
      case .busy:                   return SQLITE_BUSY
      case .locked:                 return SQLITE_LOCKED
      case .noMem:                  return SQLITE_NOMEM
      case .readOnly:               return SQLITE_READONLY
      case .interrupt:              return SQLITE_INTERRUPT
      case .ioErr:                  return SQLITE_IOERR
      case .corrupt:                return SQLITE_CORRUPT
      case .notFound:               return SQLITE_NOTFOUND
      case .full:                   return SQLITE_FULL
      case .cantOpen:               return SQLITE_CANTOPEN
      case .`protocol`:             return SQLITE_PROTOCOL
      case .empty:                  return SQLITE_EMPTY
      case .schema:                 return SQLITE_SCHEMA
      case .tooBig:                 return SQLITE_TOOBIG
      case .constraint:             return SQLITE_CONSTRAINT
      case .mismatch:               return SQLITE_MISMATCH
      case .misuse:                 return SQLITE_MISUSE
      case .noLfs:                  return SQLITE_NOLFS
      case .auth:                   return SQLITE_AUTH
      case .format:                 return SQLITE_FORMAT
      case .range:                  return SQLITE_RANGE
      case .notADb:                 return SQLITE_NOTADB
      case .notice:                 return SQLITE_NOTICE
      case .warning:                return SQLITE_WARNING
      case .row:                    return SQLITE_ROW
      case .done:                   return SQLITE_DONE
      case .okLoadPermanently:      return 256
      case .errorMissingCollSeq:    return 257
      case .busyRecovery:           return 261
      case .lockedShardCache:       return 262
      case .readOnlyRecovery:       return 264
      case .ioErrRead:              return 266
      case .corruptVTab:            return 267
      case .cantOpenNotEmpDir:      return 270
      case .constraintCheck:        return 275
      case .noticeRecoverWal:       return 283
      case .warningAutoIndex:       return 284
      case .errorRetry:             return 513
      case .abortRollback:          return 516
      case .busySnapshot:           return 517
      case .lockedVTab:             return 518
      case .readOnlyCantLock:       return 520
      case .ioErrShortRead:         return 522
      case .corruptSequence:        return 523
      case .cantOpenIsDir:          return 526
      case .constraintCommitHook:   return 531
      case .noticeRecoverRollback:  return 539
      case .errorSnapshot:          return 769
      case .readOnlyRollback:       return 776
      case .ioErrWrite:             return 778
      case .cantOpenFullPath:       return 782
      case .constraintForeignKey:   return 787
      case .readOnlyDbMoved:        return 1032
      case .ioErrFSync:             return 1034
      case .cantOpenConvPath:       return 1038
      case .constraintFunction:     return 1043
      case .readOnlyCantInit:       return 1288
      case .ioErrDirFSync:          return 1290
      case .cantOpenDirtyWal:       return 1294
      case .constraintNotNull:      return 1299
      case .readOnlyDirectory:      return 1544
      case .ioErrTruncate:          return 1546
      case .constraintPrimaryKey:   return 1555
      case .ioErrFStat:             return 1802
      case .constraintTrigger:      return 1811
      case .ioErrUnlock:            return 2058
      case .constraintUnique:       return 2067
      case .ioErrRdLock:            return 2314
      case .constraintVTab:         return 2323
      case .ioErrDelete:            return 2570
      case .constraintRowId:        return 2579
      case .ioErrBlocked:           return 2826
      case .ioErrNoMem:             return 3082
      case .ioErrAccess:            return 3338
      case .ioErrCheckReservedLock: return 3594
      case .ioErrLock:              return 3850
      case .ioErrClose:             return 4106
      case .ioErrDirClose:          return 4362
      case .ioErrShmOpen:           return 4618
      case .ioErrShmSize:           return 4874
      case .ioErrShmLock:           return 5130
      case .ioErrShmMap:            return 5386
      case .ioErrSeek:              return 5642
      case .ioErrDeleteNoEnt:       return 5898
      case .ioErrMMap:              return 6154
      case .ioErrGetTempPath:       return 6410
      case .ioErrConvPath:          return 6666
      case .unknown(let errorCode): return errorCode
    }
  }
  
  /// Returns a human readable message for this `SQLiteResultCode` object.
  public var message: String {
    if let cstr = sqlite3_errstr(self.rawValue) {
      return "\(String(cString: cstr)) \(self.rawValue)"
    } else {
      return "unknown sqlite3 error \(self.rawValue)"
    }
  }
  
  /// Is this result code an error?
  public var isError: Bool {
    switch self {
      case .ok, .done, .row:
        return false
      default:
        return true
    }
  }
}
