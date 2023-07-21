#if os(macOS)
import AppKit

open class UndoSettingTextView: NSTextView {
    public var settableUndoManager: UndoManager?

    public override var undoManager: UndoManager? {
        return settableUndoManager
    }
}
#else
import UIKit

open class UndoSettingTextView: UITextView {
    public var settableUndoManager: UndoManager?

    public override var undoManager: UndoManager? {
        return settableUndoManager
    }
}

#endif
