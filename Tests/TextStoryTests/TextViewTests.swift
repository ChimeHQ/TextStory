import XCTest
import TextStory
import TextStoryTesting

class TextViewTests: XCTestCase {
    func testProgrammaticModificationSupportsUndo() {
        let textView = UndoSettingTextView()
        textView.settableUndoManager = UndoManager()

        let mutation = TextMutation(string: "hello", range: NSRange.zero, limit: 0)

        textView.applyMutation(mutation)

        XCTAssertEqual(textView.string, "hello")

        textView.undoManager!.undo()

        XCTAssertEqual(textView.string, "")
    }
}
