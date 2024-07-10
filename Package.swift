// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MessageComposeView",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MessageComposeView",
            targets: ["MessageComposeView"]),
    ],
    targets: [
        .target(
            name: "MessageComposeView"),
        .testTarget(
            name: "MessageComposeViewTests",
            dependencies: ["MessageComposeView"]),
    ]
)
