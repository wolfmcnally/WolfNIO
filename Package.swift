// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "WolfNIO",
    platforms: [
        .iOS(.v9), .macOS(.v10_13), .tvOS(.v11)
    ],
    products: [
        .library(
            name: "WolfNIO",
            targets: ["WolfNIO"]),
        ],
    targets: [
        .target(
            name: "WolfNIO",
            dependencies: [])
        ]
)
