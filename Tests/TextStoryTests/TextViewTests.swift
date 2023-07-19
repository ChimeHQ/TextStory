import XCTest
import TextStory
import TextStoryTesting

final class TextViewTests: XCTestCase {
    @MainActor
    func testProgrammaticModificationSupportsUndo() throws {
        let textView = UndoSettingTextView()
        textView.settableUndoManager = UndoManager()
        let storage = try XCTUnwrap(textView.undoingTextStorage)

        let mutation = TextMutation(string: "hello", range: NSRange.zero, limit: 0)

        storage.applyMutation(mutation)

        #if os(macOS)
        XCTAssertEqual(textView.string, "hello")
        #elseif os(iOS)
        XCTAssertEqual(textView.text, "hello")
        #endif

        textView.undoManager!.undo()

        #if os(macOS)
        XCTAssertEqual(textView.string, "")
        #elseif os(iOS)
        XCTAssertEqual(textView.text, "")
        #endif
    }
}
