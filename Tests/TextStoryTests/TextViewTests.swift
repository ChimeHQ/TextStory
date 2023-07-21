import XCTest
import TextStory
import TextStoryTesting

#if canImport(AppKit)
extension NSTextView {
	var text: String { string }
}
#endif

final class TextViewTests: XCTestCase {
    @MainActor
    func testProgrammaticModificationSupportsUndo() throws {
        let textView = UndoSettingTextView()
        textView.settableUndoManager = UndoManager()
        let storage = TextStorageAdapter(textView: textView)

        let mutation = TextMutation(string: "hello", range: NSRange.zero, limit: 0)

        storage.applyMutation(mutation)

        XCTAssertEqual(textView.text, "hello")
		XCTAssertEqual(textView.selectedRange, NSRange(5..<5))

        try XCTUnwrap(textView.undoManager).undo()

        XCTAssertEqual(textView.text, "")
		XCTAssertEqual(textView.selectedRange, NSRange(0..<0))
    }
}
