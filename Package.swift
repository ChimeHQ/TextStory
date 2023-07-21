// swift-tools-version:5.5

import PackageDescription

let settings: [SwiftSetting] = [
    // .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
]

let package = Package(
    name: "TextStory",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(name: "TextStory", targets: ["TextStory"]),
        .library(name: "TextStoryTesting", targets: ["TextStoryTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/Rearrange", from: "1.5.0"),
		.package(url: "https://github.com/mattmassicotte/MainOffender", from: "0.1.0"),
    ],
    targets: [
        .target(name: "Internal", publicHeadersPath: "."),
        .target(name: "TextStory", dependencies: ["Internal", "MainOffender", "Rearrange"], swiftSettings: settings),
        .target(name: "TextStoryTesting", dependencies: ["TextStory"], swiftSettings: settings),
        .testTarget(name: "TextStoryTests", dependencies: ["TextStory", "TextStoryTesting"], swiftSettings: settings),
    ]
)
