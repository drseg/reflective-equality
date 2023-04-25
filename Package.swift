// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "reflective-equality",
    products: [
        .library(
            name: "ReflectiveEquality",
            targets: ["ReflectiveEquality"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ExceptionCatcher"),
        .target(
            name: "ReflectiveEquality",
            dependencies: ["ExceptionCatcher"]),
        .testTarget(
            name: "ReflectiveEqualityTests",
            dependencies: ["ReflectiveEquality"]),
    ]
)
