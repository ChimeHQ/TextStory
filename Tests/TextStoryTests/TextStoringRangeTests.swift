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

    func testTrailingWhitespaceWithSpaces() {
        let string = "trailing\n    abc"
        let storage = NSTextStorage(string: string)
        let range = storage.trailingWhitespaceRange(in: NSRange(0..<13))

        XCTAssertEqual(range, NSRange(8..<13))
    }

    func testLeadingWhitespaceWithTwoNewlines() {
        let string = "abc\n\ndef"
        let storage = NSTextStorage(string: string)

        XCTAssertEqual(storage.leadingWhitespaceRange(in: NSRange(3..<8)), NSRange(3..<5))
    }

    func testLeadingWhitespaceWithTab() {
        let string = "these\n\tare\n    some\n lines"
        let storage = NSTextStorage(string: string)

        XCTAssertEqual(storage.leadingWhitespaceRange(in: NSMakeRange(6, 4)), NSMakeRange(6, 1))
    }

    func testLeadingWhitespaceWithNoWhitespace() {
        let string = "these\n\tare\n    some\n lines"
        let storage = NSTextStorage(string: string)

        XCTAssertEqual(storage.leadingWhitespaceRange(in: NSMakeRange(0, 6)), NSMakeRange(0, 0))
    }

    func testLeadingWhitespaceWithSpaces() {
        let string = "these\n\tare\n    some\n lines"
        let storage = NSTextStorage(string: string)

        XCTAssertEqual(storage.leadingWhitespaceRange(in: NSMakeRange(11, 9)), NSMakeRange(11, 4))
    }
}
