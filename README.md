[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]

# TextStory

TextStory is a small set of classes and protocols for easier work with NSTextStorage and associated systems. iOS and macOS are supported.

## Integration

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/TextStory")
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

### Suggestions or Feedback

We'd love to hear from you! Get in touch via an issue or pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.


[build status]: https://github.com/ChimeHQ/TextStory/actions
[build status badge]: https://github.com/ChimeHQ/TextStory/workflows/CI/badge.svg
[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/TextStory
[platforms]: https://swiftpackageindex.com/ChimeHQ/TextStory
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FTextStory%2Fbadge%3Ftype%3Dplatforms
