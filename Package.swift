// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TextStory",
    platforms: [.macOS(.v10_12), .iOS(.v10), .tvOS(.v10)],
    products: [
        .library(name: "TextStory", targets: ["TextStory"]),
        .library(name: "TextStoryTesting", targets: ["TextStoryTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/Rearrange", from: "1.5.0")
    ],
    targets: [
        .target(name: "Internal", publicHeadersPath: "."),
        .target(name: "TextStory", dependencies: ["Internal", "Rearrange"]),
        .target(name: "TextStoryTesting", dependencies: ["TextStory"]),
        .testTarget(name: "TextStoryTests", dependencies: ["TextStory", "TextStoryTesting"]),
    ]
)
