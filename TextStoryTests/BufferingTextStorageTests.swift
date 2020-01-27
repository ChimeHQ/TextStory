//
//  BufferingTextStorageTests.swift
//  TextBaseTests
//
//  Created by Matt Massicotte on 2019-12-16.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import XCTest
import TextStory

// swiftlint:disable legacy_constructor
class BufferingTextStorageTests: XCTestCase {
    func makeStorage(_ string: String) -> BufferingTextStorage {
        let storage = BufferingTextStorage()

        storage.replaceCharacters(in: NSMakeRange(0, 0), with: string)

        storage.bufferingEnabled = true

        return storage
    }

    func testNoChanges() {
        let storage = makeStorage("hello")

        XCTAssertEqual(storage.length, 5)
        XCTAssertEqual(storage.bufferedLength, 5)
    }

    func testSubstringWithNoChanges() {
        let storage = makeStorage("hello")

        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "hello")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(2, 1)), "l")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(3, 2)), "lo")
    }

    func testSingleCharacterAddition() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(5, 0), with: ", goodbye")

        XCTAssertEqual(storage.string, "hello, goodbye")
        XCTAssertEqual(storage.bufferedLength, 5)
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "hello")
    }

    func testSingleCharacterRemoval() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(0, 3), with: "e")

        XCTAssertEqual(storage.string, "elo")
        XCTAssertEqual(storage.bufferedLength, 5)
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "hello")
    }

    func testMulipleChanges() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(5, 0), with: ", goodbye")
        storage.replaceCharacters(in: NSMakeRange(7, 4), with: "")
        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "well, ")

        XCTAssertEqual(storage.string, "well, hello, bye")
        XCTAssertEqual(storage.bufferedLength, 5)
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "hello")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(4, 1)), "o")
    }

    func testMulipleDeletionsBeforeSubstringRange() {
        let storage = makeStorage("well (going to be removed), hello")

        storage.replaceCharacters(in: NSMakeRange(6, 19), with: "")
        storage.replaceCharacters(in: NSMakeRange(4, 3), with: "")

        XCTAssertEqual(storage.string, "well, hello")
        XCTAssertEqual(storage.bufferedLength, 33)
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 4)), "well")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(12, 5)), "to be")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(28, 5)), "hello")
    }

    func testMulipleInsertionsBeforeSubstringRange() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "well, ")
        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "oh ")

        XCTAssertEqual(storage.string, "oh well, hello")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "hello")
    }

    func testSingleInsertionsAfterSubstringRange() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(5, 0), with: " there")

        XCTAssertEqual(storage.string, "hello there")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(4, 1)), "o")
    }

    func testSingleInsertionWithinSubstringRange() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(2, 0), with: "ll")

        XCTAssertEqual(storage.string, "hellllo")
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(4, 1)), "o")
    }

    func testApplyingMultipleChanges() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "well, ")
        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "oh ")

        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "hello")

        XCTAssertEqual(storage.bufferedLength, 5)
        storage.applyNextChange()
        XCTAssertEqual(storage.bufferedLength, 11)
        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "well,")

        storage.applyNextChange()
        XCTAssertEqual(storage.bufferedLength, 14)

        XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(0, 5)), "oh we")
    }

    // MARK: Performance
    func testSubstringPerformanceWithNoChanges() {
        let storage = makeStorage("hello")

        for _ in 0..<100 {
            let bigString = String(repeating: "ten__chars", count: 1000)

            storage.replaceCharacters(in: NSMakeRange(0, 0), with: bigString)

            storage.clearBuffer()
        }

        XCTAssertEqual(storage.length, 1000005)

        self.measure {
            for _ in 0..<10000 {
                XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(1000000, 5)), "hello")
            }
        }
    }

    func testSubstringPerformanceWithOneChange() {
        let storage = makeStorage("hello")

        for _ in 0..<100 {
            let bigString = String(repeating: "ten__chars", count: 1000)

            storage.replaceCharacters(in: NSMakeRange(0, 0), with: bigString)

            storage.clearBuffer()
        }

        XCTAssertEqual(storage.length, 1000005)

        storage.replaceCharacters(in: NSMakeRange(1000005, 0), with: ", goodbye")

        self.measure {
            for _ in 0..<10000 {
                XCTAssertEqual(storage.bufferedSubstring(from: NSMakeRange(1000000, 5)), "hello")
            }
        }
    }

    // MARK: Range transformations
    func testAdditionAtEndRangeTransform() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(5, 0), with: ", goodbye")

        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(0, 5)), NSMakeRange(0, 5))
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(0, 0)), NSMakeRange(0, 0))
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(5, 0)), NSMakeRange(5, 0))
    }

    func testAdditionAtBeginningRangeTransform() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "well, ")

        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(0, 5)), NSMakeRange(6, 5))
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(0, 0)), NSMakeRange(0, 0))
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(5, 0)), NSMakeRange(11, 0))
    }

    func testRemovalAtBeginningRangeTransform() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(0, 2), with: "")

        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(0, 5)), NSMakeRange(0, 3))
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(0, 0)), NSMakeRange(0, 0))
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(1, 0)), nil)
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(5, 0)), NSMakeRange(3, 0))
    }

    func testMultipleChangeRangeTransformation() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSRange(location: 5, length: 0), with: ", goodbye") // "hello, goodbye"
        storage.replaceCharacters(in: NSRange(location: 7, length: 4), with: "")          // "hello, bye"
        storage.replaceCharacters(in: NSRange(location: 0, length: 0), with: "well, ")    // "well, hello, bye"

        XCTAssertEqual(storage.string, "well, hello, bye")

        let transformed = storage.transformBaseRange(NSRange(location: 0, length: 5))
        XCTAssertEqual(transformed, NSRange(location: 6, length: 5))
    }

    func testMultipleChangeWithinRangeTransformation() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSRange(location: 2, length: 1), with: "")       // "helo"
        storage.replaceCharacters(in: NSRange(location: 0, length: 0), with: "well, ") // "well, helo"

        XCTAssertEqual(storage.string, "well, helo")

        let transformed = storage.transformBaseRange(NSRange(location: 0, length: 5))
        XCTAssertEqual(transformed, NSRange(location: 6, length: 4))
    }

    func testMulipleInsertionsBeforeRangeTransformation() {
        let storage = makeStorage("hello")

        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "well, ")
        storage.replaceCharacters(in: NSMakeRange(0, 0), with: "oh ")

        XCTAssertEqual(storage.string, "oh well, hello")
        XCTAssertEqual(storage.transformBaseRange(NSMakeRange(0, 5)), NSMakeRange(9, 5))
    }

}
