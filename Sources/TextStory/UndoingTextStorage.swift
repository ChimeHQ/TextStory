import Foundation

/// A `TextStoring` implementation that uses closures to wrap both an internal `TextStoring` and `UndoManager`.
///
/// This class exists to help connect a `MainActor`-isolated system to a `TextStoring`-compatible type.
///
/// - Warning: Pay careful attention to the lifetime of this object. It must live long enough to satisify any undo/redo requests for the view.
public final class UndoingTextStorage {
    public typealias UndoManagerProvider = () -> UndoManager?
    public typealias StorageProvider = () -> TextStoring?

    public let storageProvider: StorageProvider
    public let undoManagerProvider: UndoManagerProvider

    public init(storageProvider: @escaping StorageProvider, undoManagerProvider: @escaping UndoManagerProvider) {
        self.storageProvider = storageProvider
        self.undoManagerProvider = undoManagerProvider
    }
}

extension UndoingTextStorage: TextStoring {
    public var length: Int {
        storageProvider()?.length ?? 0
    }

    public func substring(from range: NSRange) -> String? {
        storageProvider()?.substring(from: range)
    }

    public func applyMutation(_ mutation: TextMutation) {
        let inverse = inverseMutation(for: mutation)

        undoManagerProvider()?.registerUndo(withTarget: self, handler: { storage in
            storage.applyMutation(inverse)
        })

        storageProvider()?.applyMutation(mutation)
    }
}

#if canImport(AppKit)
import AppKit

extension UndoingTextStorage {
    @MainActor
    public convenience init(view: NSTextView) {
        self.init(storageProvider: { view.textStorage }, undoManagerProvider: { view.undoManager })
    }
}

extension NSTextView {
    /// Create an UndoingTextStorage for this view.
    public var undoingTextStorage: UndoingTextStorage? {
        UndoingTextStorage(view: self)
    }
}
#elseif canImport(UIKit)
import UIKit

extension UndoingTextStorage {
    @MainActor
    public convenience init(view: UITextView) {
        self.init(storageProvider: { view.textStorage }, undoManagerProvider: { view.undoManager })
    }
}

extension UITextView {
    /// Create an UndoingTextStorage for this view.
    public var undoingTextStorage: UndoingTextStorage? {
        UndoingTextStorage(view: self)
    }
}
#endif
