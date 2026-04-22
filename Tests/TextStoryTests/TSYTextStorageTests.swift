#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#else
import UIKit
#endif
import Foundation
import Testing

import TextStory

class MockDelegate: NSObject, TSYTextStorageDelegate {
	enum Event {
		case willReplace(NSRange, String)
		case didReplace(NSRange, String)
		case didProcessEnding
	}

	var events = [Event]()

	func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

	}

	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

	}

	func textStorage(_ textStorage: TSYTextStorage, willReplaceCharactersIn range: NSRange, with string: String) {
		events.append(.willReplace(range, string))
	}

	func textStorage(_ textStorage: TSYTextStorage, didReplaceCharactersIn range: NSRange, with string: String) {
		events.append(.didReplace(range, string))
	}
}

struct TSYTextStorageTests {
	@Test
	func testBeginEndEdit() throws {
		let delegate = MockDelegate()
		let storage = NSTextStorage(string: "hello")

		storage.delegate = delegate

		storage.beginEditing()

		storage.replaceCharacters(in: NSRange(0..<1), with: "")

		#expect(storage.length == 4)

		storage.replaceCharacters(in: NSRange(3..<4), with: "")

		storage.endEditing()

		#expect(storage.string == "ell")

		print(delegate.events)
	}

}
