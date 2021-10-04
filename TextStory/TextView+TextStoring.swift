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
#endif
