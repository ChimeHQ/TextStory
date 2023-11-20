import Foundation

public protocol TextStorageMonitor {
	func textStorage(_ textStorage: TSYTextStorage, willReplaceCharactersIn range: NSRange, with string: String)
	func textStorage(_ textStorage: TSYTextStorage, didReplaceCharactersIn range: NSRange, with string: String)
	func textStorageWillCompleteProcessingEdit(_ textStorage: TSYTextStorage)
	func textStorageDidCompleteProcessingEdit(_ textStorage: TSYTextStorage)
}

public extension TextStorageMonitor {
	func textStorage(_ textStorage: TSYTextStorage, willReplaceCharactersIn range: NSRange, with string: String) {}
	func textStorageWillCompleteProcessingEdit(_ textStorage: TSYTextStorage) {}
	func textStorageDidCompleteProcessingEdit(_ textStorage: TSYTextStorage) {}
}

/// Routes `TSYTextStorageDelegate` calls to multiple `TextStorageMonitor` instances.
///
/// This class can except all the `TSYTextStorageDelegate` calls and forward them to multiple `TextStorageMonitor` instances. It can be directly assigned as the `storageDelegate` of `TSYTextStorageDelegate`.
public final class TextStorageEventRouter: NSObject {
	public typealias DoubleClickWordRangeProvider = (Int) -> NSRange
	public typealias WordBoundaryProvider = (Int, Bool) -> Int

	public var monitors = [TextStorageMonitor]()
	public var doubleClickWordRangeProvider: DoubleClickWordRangeProvider?
	public var workBoundaryProvider: WordBoundaryProvider?

	public override init() {
	}
}

extension TextStorageEventRouter: TSYTextStorageDelegate {
	public func textStorage(_ textStorage: TSYTextStorage, willReplaceCharactersIn range: NSRange, with string: String) {
		for monitor in monitors {
			monitor.textStorage(textStorage, willReplaceCharactersIn: range, with: string)
		}
	}

	public func textStorage(_ textStorage: TSYTextStorage, didReplaceCharactersIn range: NSRange, with string: String) {
		for monitor in monitors {
			monitor.textStorage(textStorage, didReplaceCharactersIn: range, with: string)
		}
	}

	public func textStorageWillCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
		for monitor in monitors {
			monitor.textStorageWillCompleteProcessingEdit(textStorage)
		}
	}

	public func textStorageDidCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
		for monitor in monitors {
			monitor.textStorageDidCompleteProcessingEdit(textStorage)
		}
	}

#if os(macOS)
	public func textStorage(_ textStorage: TSYTextStorage, doubleClickRangeForLocation location: UInt) -> NSRange {
		if let provider = doubleClickWordRangeProvider {
			return provider(Int(location))
		}
		
		return textStorage.internalStorage.doubleClick(at: Int(location))
	}

	public func textStorage(_ textStorage: TSYTextStorage, nextWordIndexFromLocation location: UInt, direction forward: Bool) -> UInt {
		if let provider = workBoundaryProvider {
			return UInt(provider(Int(location), forward))
		}

		return UInt(textStorage.internalStorage.nextWord(from: Int(location), forward: forward))
	}
#endif
}
