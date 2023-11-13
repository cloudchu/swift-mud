// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-mud",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.61.0")),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.5.3")),
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "2.4.2")),
        .package(url: "git@github.com:apple/swift-nio-ssh.git", .upToNextMajor(from: "0.8.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "swift-mud",
        dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "NIOSSH", package: "swift-nio-ssh"),
        ])
    ]
)
