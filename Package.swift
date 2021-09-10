// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Secrets",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "Secrets",
            targets: ["Secrets"]),
    ],
    dependencies: [
        .package(name: "Archivable", url: "https://github.com/archivable/package.git", .branch("main"))
    ],
    targets: [
        .target(
            name: "Secrets",
            dependencies: ["Archivable"],
            path: "Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["Secrets"],
            path: "Tests"),
    ]
)
