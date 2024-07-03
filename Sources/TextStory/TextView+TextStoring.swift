import Foundation

#if os(macOS)
import class AppKit.NSTextView

extension NSTextView: TextStoring {
    public nonisolated var length: Int {
		MainActor.assumeIsolated {
			textStorage?.length ?? 0
		}
    }

    public nonisolated func substring(from range: NSRange) -> String? {
		MainActor.assumeIsolated {
			textStorage?.substring(from: range)
		}
    }

    public nonisolated func applyMutation(_ mutation: TextMutation) {
		MainActor.assumeIsolated {
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
		MainActor.assumeIsolated {
			textStorage.length
		}
    }

    public nonisolated func substring(from range: NSRange) -> String? {
		MainActor.assumeIsolated {
			textStorage.substring(from: range)
		}
    }

    public nonisolated func applyMutation(_ mutation: TextMutation) {
		MainActor.assumeIsolated {
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
