// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "base85",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "base85",
            targets: ["base85"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "base85",
            dependencies: []),
        .testTarget(
            name: "base85Tests",
            dependencies: ["base85"]),
    ]
)
