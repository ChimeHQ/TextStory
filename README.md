<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]
[![Matrix][matrix badge]][matrix]

</div>

# TextStory

TextStory is a small set of classes and protocols for easier work with NSTextStorage and associated systems.

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/TextStory", from: "0.9.0")
]
```

## TSYTextStorage

A minimal `NSTextStorage` subclass that provides hooks for much more powerful delegate behavior. Great for separating logic/behavior from your storage object. Because it is built to wrap another `NSTextStorage` instance, it is more easily composable.

Unfortunately, to date I've not been able to figure out a way to build this class in Swift. If you have experience working with `NSTextStorage` and Swift/ObjC automatic NSString/String bridging, I'd love to hear from you.

```objc
- (void)textStorage:(TSYTextStorage *)textStorage willReplaceCharactersInRange:(NSRange)range withString:(NSString *)string;
- (void)textStorage:(TSYTextStorage *)textStorage didReplaceCharactersInRange:(NSRange)range withString:(NSString *)string;
- (void)textStorageProcessEditingComplete:(TSYTextStorage *)textStorage;

// available for macOS only
- (NSRange)textStorage:(TSYTextStorage *)textStorage doubleClickRangeForLocation:(NSUInteger)location;
- (NSUInteger)textStorage:(TSYTextStorage *)textStorage nextWordIndexFromLocation:(NSUInteger)location direction:(BOOL)forward;
```

## BufferingTextStorage

An `NSTextStorage` subclass that maintains a history of text changes with low memory and performance overhead. This class makes it possible to decouple text change processing from them Cocoa text display system, making them asynchronous with respect to each other. Very useful for keeping your UI fast and responsive even if the processing of changes can be slow.

```swift
// interact with the buffered view of text
func bufferedSubstring(from range: NSRange) -> String
var bufferedLength: Int

// commit one change in the queue, allowing precise control over how the buffered view changes
func applyNextChange()
```

## TextStoring

A simple protocol that abstracts string storage. This is very useful for standardizing behavior across `NSTextStorage` and other objects you may use for text manipulation. Particularly handy for testing and decoupling systems from Apple's classes behaviors/APIs.

In order to maintain flexiblity and match `NSTextStorage`, `TextStoring` is not actor-isolated.

## TextStorageAdapter

It isn't possible to make `NSTextView`/`UITextView` conform to `TextStoring`, because they are `MainActor`-isolated classes. This adapter exists to help use a view with `TextStoring`.

## TextStoringMonitor

Standard interface for systems that need to observe and react to changes in a `TextStoring` instance.

## LazyTextStoringMonitor

A concrete `TextStoringMonitor` class that implements progressive, on-demand access to a wrapped `TextStoringMonitor`. This makes it easy to add lazy semantics on top of an existing `TextStoringMonitor`, which can be very helpful for handling large documents.

## CompositeTextStoringMonitor

An easy way to group together a collection of `TextStoringMonitor` instances and tread them as a single unit.

## TextMutationEventRouter

This class can accept and route `TSYTextStorage` delegate callbacks to multiple `TextStoringMonitor` instances. This is super handy for faning-out these calls.

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great. Both a [Matrix space][matrix] and [Discord][discord] are available for live help, but I have a strong bias towards answering in the form of documentation. You can also find me on [the web](https://www.massicotte.org).

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/ChimeHQ/TextStory/actions
[build status badge]: https://github.com/ChimeHQ/TextStory/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/ChimeHQ/TextStory
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FTextStory%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/TextStory/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
[matrix]: https://matrix.to/#/%23chimehq%3Amatrix.org
[matrix badge]: https://img.shields.io/matrix/chimehq%3Amatrix.org?label=Matrix
[discord]: https://discord.gg/esFpX6sErJ
