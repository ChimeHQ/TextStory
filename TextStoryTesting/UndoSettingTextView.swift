#if os(macOS)
import AppKit.NSTextView

open class UndoSettingTextView: NSTextView {
    public var settableUndoManager: UndoManager?

    public override var undoManager: UndoManager? {
        return settableUndoManager
    }
}
#endif
