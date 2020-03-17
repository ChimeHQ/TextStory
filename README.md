[![Github CI](https://github.com/ChimeHQ/TextStory/workflows/CI/badge.svg)](https://github.com/ChimeHQ/TextStory/actions)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)

# TextStory

TextStory is a small set of classes and protocols for easier work with NSTextStorage and associated systems. iOS and macOS are supported.

## Integration

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/TextStory")
]
```

Carthage:

```
github "ChimeHQ/TextStory"
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

A simple protocol that abstracts string storage. This is very useful for standardizing behavior across `NSTextStorage`, `NSTextView` and other objects you may use for text manipulation. Particularly handy for testing and decoupling systems from Apple's classes behaviors/APIs.

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
