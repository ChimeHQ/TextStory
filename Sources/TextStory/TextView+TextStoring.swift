import Foundation

extension MainActor {
	/// Execute the given body closure on the main actor without enforcing MainActor isolation.
	///
	/// It will crash if run on any non-main thread.
	///
	/// This was copied from the MainOffender library
	@_unavailableFromAsync
	static func runUnsafely<T>(_ body: @MainActor () throws -> T) rethrows -> T {
#if swift(>=5.9)
		if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
			return try MainActor.assumeIsolated(body)
		}
#endif

		dispatchPrecondition(condition: .onQueue(.main))
		return try withoutActuallyEscaping(body) { fn in
			try unsafeBitCast(fn, to: (() throws -> T).self)()
		}
	}
}

#if os(macOS)
import class AppKit.NSTextView

extension NSTextView: TextStoring {
    public nonisolated var length: Int {
		MainActor.runUnsafely {
			textStorage?.length ?? 0
		}
    }

    public nonisolated func substring(from range: NSRange) -> String? {
		MainActor.runUnsafely {
			textStorage?.substring(from: range)
		}
    }

    public nonisolated func applyMutation(_ mutation: TextMutation) {
		MainActor.runUnsafely {
			if let manager = undoManager {
				let inverse = inverseMutation(for: mutation)
				
				manager.registerUndo(withTarget: self, handler: { (storable) in
					storable.applyMutation(inverse)
				})
			}
			
			replaceCharacters(in: mutation.range, with: mutation.string)
			
			didChangeText()
		}
    }
}
#else
import UIKit

extension UITextView: TextStoring {
    public nonisolated var length: Int {
		MainActor.runUnsafely {
			textStorage.length
		}
    }

    public nonisolated func substring(from range: NSRange) -> String? {
		MainActor.runUnsafely {
			textStorage.substring(from: range)
		}
    }

    public nonisolated func applyMutation(_ mutation: TextMutation) {
		MainActor.runUnsafely {
			if let manager = undoManager {
				let inverse = inverseMutation(for: mutation)

				manager.registerUndo(withTarget: self, handler: { (storable) in
					storable.applyMutation(inverse)
				})
			}

			guard let start = position(from: self.beginningOfDocument, offset: mutation.range.location) else {
				preconditionFailure("Unable to determine range start location")
			}

			guard let end = position(from: start, offset: mutation.range.length) else {
				preconditionFailure("Unable to determine range end location")
			}

			guard let range = textRange(from: start, to: end) else {
				preconditionFailure("Unable to build range from start and end")
			}

			replace(range, withText: mutation.string)
		}
    }
}
#endif
