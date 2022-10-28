import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
extension NSTextContentStorage: TextStoring {
	public var length: Int {
		return textStorage?.length ?? 0
	}

	public func applyMutation(_ mutation: TextMutation) {
		textStorage?.applyMutation(mutation)
	}

	public func substring(from range: NSRange) -> String? {
		return textStorage?.substring(from: range)
	}
}
