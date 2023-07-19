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

        #if canImport(AppKit)
        XCTAssertEqual(textView.string, "hello")
        #elseif canImport(UIKit)
        XCTAssertEqual(textView.text, "hello")
        #endif

        textView.undoManager!.undo()

        #if canImport(AppKit)
        XCTAssertEqual(textView.string, "")
        #elseif canImport(UIKit)
        XCTAssertEqual(textView.text, "")
        #endif
    }
}
