// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Lingo Leitner",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Lingo Leitner",
            targets: ["Lingo Leitner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "Lingo Leitner",
            dependencies: ["SnapKit", "SDWebImage"]),
        .testTarget(
            name: "Lingo LeitnerTests",
            dependencies: ["Lingo Leitner"]),
    ]
) 