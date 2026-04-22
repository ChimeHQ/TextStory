// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "TextStory",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.visionOS(.v1),
	],
	products: [
		.library(name: "TextStory", targets: ["TextStory"]),
		.library(name: "TextStoryTesting", targets: ["TextStoryTesting"]),
	],
	dependencies: [
		.package(url: "https://github.com/ChimeHQ/Rearrange", from: "2.0.0"),
	],
	targets: [
		.target(name: "Internal", publicHeadersPath: "."),
		.target(name: "TextStory", dependencies: ["Internal", "Rearrange"]),
		.target(name: "TextStoryTesting", dependencies: ["TextStory"]),
		.testTarget(name: "TextStoryTests", dependencies: ["TextStory", "TextStoryTesting"]),
	]
)
