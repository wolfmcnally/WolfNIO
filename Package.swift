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
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.2.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "WolfNIO",
            dependencies: ["NIO", "NIOTransportServices"])
        ]
)
