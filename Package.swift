// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SegmentAdjust",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SegmentAdjust",
            targets: ["SegmentAdjust", "Segment"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Adjust", url: "https://github.com/adjust/ios_sdk", from: "4.27.1"),
//        .package(name: "Segment", url: "git@github.com:segmentio/analytics-ios.git", from: "4.1.5"),
//        .package(
//                    name: "Segment",
//            url: "git@github.com:segmentio/analytics-ios.git", from: "4.1.5"
//                )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SegmentAdjust",
            dependencies: ["Adjust"]),
        .binaryTarget(name: "Segment", path: "./Segment.xcframework")
    ]
)
