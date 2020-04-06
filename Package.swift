// swift-tools-version:5.1
//
//  Package.swift
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

import PackageDescription

let package = Package(
  name: "SQLiteExpress",
  
  // Platforms define the operating systems for which this library can be compiled for.
  platforms: [
    .macOS(.v10_13),
    .iOS(.v12),
  ],
  
  // Products define the executables and libraries produced by a package, and make them visible
  // to other packages.
  products: [
    .library(name: "SQLiteExpress", targets: ["SQLiteExpress"]),
  ],
  
  // Dependencies declare other packages that this package depends on.
  // e.g. `.package(url: /* package url */, from: "1.0.0"),`
  dependencies: [
  ],
  
  // Targets are the basic building blocks of a package. A target can define a module or
  // a test suite. Targets can depend on other targets in this package, and on products
  // in packages which this package depends on.
  targets: [
    .target(name: "SQLiteExpress", dependencies: []),
    .testTarget(name: "SQLiteExpressTests", dependencies: ["SQLiteExpress"]),
  ],
  
  // Required Swift language version.
  swiftLanguageVersions: [.v5]
)
