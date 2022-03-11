import XCTest
import TextStory

final class TextStoringRangeTests: XCTestCase {
    func testLineRanges() {
        let storage = NSTextStorage(string: "abc\ndef")

        XCTAssertEqual(storage.lineRange(containing: 0), NSRange(0..<4))
        XCTAssertEqual(storage.lineRange(containing: 4), NSRange(4..<7))
        XCTAssertEqual(storage.lineRange(containing: 7), NSRange(4..<7))
    }

    func testLineRangesOfEmptyString() {
        let storage = NSTextStorage(string: "")

        XCTAssertEqual(storage.lineRange(containing: 0), NSRange(0..<0))
    }
}
