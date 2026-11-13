// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Labubu",
    defaultLocalization: "de",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LabubuApp",
            targets: ["LabubuApp"]
        )
    ],
    targets: [
        .target(
            name: "LabubuApp",
            path: "Sources/LabubuApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
