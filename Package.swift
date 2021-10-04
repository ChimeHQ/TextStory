// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TextStory",
    platforms: [.macOS(.v10_12), .iOS(.v10)],
    products: [
        .library(name: "TextStory", targets: ["TextStory"]),
        .library(name: "TextStoryTesting", targets: ["TextStoryTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/Rearrange.git", from: "1.1.2")
    ],
    targets: [
        // If you can figure out how to improve this situation, you get a cookie.

        // hack #1 - ObjC needs to be in a dedicated target,
        // hack #2 - those targets seem seem to require sources and headers in different directories
        .target(name: "Internal", dependencies: [], path: "Internal", publicHeadersPath: "include"),
        .target(name: "TextStory",
            dependencies: ["Internal", "Rearrange"],
            path: "TextStory",
            exclude: ["TSYTextStorage.m", "TSYTextStorage.h"],
            // hack #3 - the import statement needs to be conditional, so Xcode builds work normally
            swiftSettings: [.define("SPM_BUILD")]
        ),
        .target(name: "TextStoryTesting", dependencies: ["TextStory"], path: "TextStoryTesting"),
        .testTarget(name: "TextStoryTests", dependencies: ["TextStory", "TextStoryTesting"], path: "TextStoryTests/"),
    ]
)
