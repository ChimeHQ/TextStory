//
//  TextStoringTests.swift
//  TextStoryTests
//
//  Created by Matt Massicotte on 2020-01-19.
//  Copyright © 2020 Chime Systems Inc. All rights reserved.
//

import XCTest
import TextStory

class TextStoringTests: XCTestCase {
    func testApplyMutation() {
        let storage = NSTextStorage(string: "")

        let mutation = TextMutation(string: "hello", range: NSRange(location: 0, length: 0), limit: 0)

        storage.applyMutation(mutation)

        XCTAssertEqual(storage.string, "hello")
    }

    func testInverseMutation() {
        let storage = NSTextStorage(string: "")

        let mutation = TextMutation(string: "hello", range: NSRange(location: 0, length: 0), limit: 0)

        storage.applyMutation(mutation)

        let inverse = storage.inverseMutation(for: mutation)

        storage.applyMutation(inverse)

        XCTAssertEqual(storage.string, "")
    }

    func testApplyMutations() {
        let storage = NSTextStorage(string: "abc")

        let mutations = [
            TextMutation(string: "f", range: NSRange(2..<3), limit: 3),
            TextMutation(string: "d", range: NSRange(0..<1), limit: 3),
            TextMutation(string: "", range: NSRange(1..<2), limit: 3)
        ]

        storage.applyMutations(mutations)

        XCTAssertEqual(storage.string, "df")
    }

    func testPostApplyRangeWithAddition() {
        let mutation = TextMutation(string: "hello", range: NSRange(0..<0), limit: 0)

        XCTAssertEqual(mutation.postApplyRange, NSRange(0..<5))
    }

    func testPostApplyRangeWithDeletion() {
        let mutation = TextMutation(string: "", range: NSRange(0..<5), limit: 0)

        XCTAssertEqual(mutation.postApplyRange, NSRange(0..<0))
    }

    func testPostApplyRangeWithFullReplacement() {
        let mutation = TextMutation(string: "hello", range: NSRange(0..<5), limit: 0)

        XCTAssertEqual(mutation.postApplyRange, NSRange(0..<5))
    }

    func testPostApplyRangeWithAdditionReplacement() {
        let mutation = TextMutation(string: "hh", range: NSRange(0..<1), limit: 0)

        XCTAssertEqual(mutation.postApplyRange, NSRange(0..<2))
    }
}
