// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PureLiveCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "PureLiveCore", targets: ["PureLiveCore"])
    ],
    targets: [
        .target(name: "PureLiveCore", path: "PureLive/CorePackage"),
        .testTarget(name: "PureLiveCoreTests", dependencies: ["PureLiveCore"], path: "PureLive/CorePackageTests")
    ]
)
