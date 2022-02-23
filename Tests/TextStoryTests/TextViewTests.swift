import XCTest
import TextStory
import TextStoryTesting
#if os(macOS)
import class AppKit.NSTextView
#else
#endif

class TextViewTests: XCTestCase {
#if os(macOS)
    func testProgrammaticModificationSupportsUndo() {
        let textView = UndoSettingTextView()
        textView.settableUndoManager = UndoManager()

        let mutation = TextMutation(string: "hello", range: NSRange.zero, limit: 0)

        textView.applyMutation(mutation)

        XCTAssertEqual(textView.string, "hello")

        textView.undoManager!.undo()

        XCTAssertEqual(textView.string, "")
    }
#endif
}
