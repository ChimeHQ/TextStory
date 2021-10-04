#if os(macOS)
import AppKit.NSTextView

public class UndoSettingTextView: NSTextView {
    public var settableUndoManager: UndoManager?

    public override var undoManager: UndoManager? {
        return settableUndoManager
    }
}
#endif
