import XCTest
import TextStory
import TextStoryTesting

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension NSTextView {
	var text: String { string }
}
#endif

final class TextViewTests: XCTestCase {
	#if !os(visionOS)
	// this test hangs in GitHub actions for some reason...
    @MainActor
    func testProgrammaticModificationSupportsUndo() throws {
        let textView = UndoSettingTextView()
        textView.settableUndoManager = UndoManager()

        let mutation = TextMutation(string: "hello", range: NSRange.zero, limit: 0)

		textView.applyMutation(mutation)

        XCTAssertEqual(textView.text, "hello")
		XCTAssertEqual(textView.selectedRange, NSRange(5..<5))

        try XCTUnwrap(textView.undoManager).undo()

        XCTAssertEqual(textView.text, "")
		XCTAssertEqual(textView.selectedRange, NSRange(0..<0))
    }
	#endif
}
