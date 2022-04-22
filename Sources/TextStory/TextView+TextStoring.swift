import Foundation
#if os(macOS)
import class AppKit.NSTextView

extension NSTextView: TextStoring {
    public var length: Int {
        return textStorage?.length ?? 0
    }

    public func substring(from range: NSRange) -> String? {
        return textStorage?.substring(from: range)
    }

    public func applyMutation(_ mutation: TextMutation) {
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
#else
import UIKit

extension UITextView: TextStoring {
    public var length: Int {
        return textStorage.length
    }

    public func substring(from range: NSRange) -> String? {
        return textStorage.substring(from: range)
    }

    public func applyMutation(_ mutation: TextMutation) {
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
#endif
