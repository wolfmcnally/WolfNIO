// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "WolfNIO",
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