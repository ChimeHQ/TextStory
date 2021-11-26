import XCTest
import TextStory
import TextStoryTesting

extension TextStoringMonitor {
    func applyMutation(_ mutation: TextMutation, to storage: TextStoring) {
        willApplyMutation(mutation, to: storage)
        storage.applyMutation(mutation)
        didApplyMutation(mutation, to: storage)
        willCompleteChangeProcessing(of: mutation, in: storage)
        didCompleteChangeProcessing(of: mutation, in: storage)
    }

    func applyMutations(_ mutations: [TextMutation], to storage: TextStoring) {
        for mutation in mutations {
            applyMutation(mutation, to: storage)
        }
    }
}

final class LazyTextStoringMontiorTests: XCTestCase {
    func testEnsuresProcessingForMutation() {
        let mockMonitor = MockTextStoringMonitor()
        let storage = NSTextStorage(string: "abcdef")

        let lazyMonitor = LazyTextStoringMonitor(storingMonitor: mockMonitor)

        let mutations = [
            // add "gh" to the end
            TextMutation(string: "gh", range: NSRange(location: 6, length: 0), limit: 6),

            // then add "ijk" to the end
            TextMutation(string: "ijk", range: NSRange(location: 8, length: 0), limit: 8),

            // then, delete "bc" from the middle
            TextMutation(string: "", range: NSRange(location: 1, length: 2), limit: 11),
        ]

        let visibleMutations = [
            TextMutation(string: "abcdef", range: NSRange(location: 0, length: 0), limit: 0),
            mutations[0],
            mutations[1],
            mutations[2],
        ]

        var appliedMutations: [TextMutation] = []

        let willApplyExpectation = XCTestExpectation(description: "willApply")
        willApplyExpectation.expectedFulfillmentCount = mutations.count
        mockMonitor.willApplyBlock = { (mutation, _) in
            appliedMutations.append(mutation)
            willApplyExpectation.fulfill()
        }

        let didApplyExpectation = XCTestExpectation(description: "didApply")
        didApplyExpectation.expectedFulfillmentCount = mutations.count
        mockMonitor.didApplyBlock = { (mutation, _) in
            XCTAssertEqual(mutation, appliedMutations.last)

            didApplyExpectation.fulfill()
        }

        lazyMonitor.applyMutations(mutations, to: storage)

        wait(for: [willApplyExpectation], timeout: 0.1)
        wait(for: [didApplyExpectation], timeout: 0.1)

        XCTAssertEqual(appliedMutations, visibleMutations)
    }

    func testMinimumDelta() {
        let mockMonitor = MockTextStoringMonitor()
        let storage = NSTextStorage(string: "abcdef")

        let lazyMonitor = LazyTextStoringMonitor(storingMonitor: mockMonitor)
        lazyMonitor.minimumDelta = 3

        var appliedMutation: TextMutation? = nil

        mockMonitor.willApplyBlock = { (mutation, _) in
            appliedMutation = mutation
        }

        // read 2 characters, less than the minimum
        let location = 2

        XCTAssertTrue(location < lazyMonitor.minimumDelta)

        lazyMonitor.ensureTextProcessed(upTo: location, in: storage)

        let expectedMutation = TextMutation(string: "abc", range: NSRange(location: 0, length: 0), limit: 0)

        XCTAssertEqual(appliedMutation, expectedMutation)
    }

    func testMutationBeforeLimitHasBeenReached() {
        let mockMonitor = MockTextStoringMonitor()
        let storage = NSTextStorage(string: "abcdefghi")

        let lazyMonitor = LazyTextStoringMonitor(storingMonitor: mockMonitor)
        lazyMonitor.minimumDelta = 3

        let mutations = [
            // add "1" after "c"
            TextMutation(string: "1", range: NSRange(3..<3), limit: 9),

            // delete "b"
            TextMutation(string: "", range: NSRange(1..<2), limit: 10),
        ]

        lazyMonitor.ensureTextProcessed(upTo: 3, in: storage)
        XCTAssertEqual(lazyMonitor.maximumProcessedLocation, 3)
        XCTAssertEqual(storage.length, 9)

        var visibleMutations: [TextMutation] = []

        mockMonitor.willApplyBlock = { (mutation, _) in
            visibleMutations.append(mutation)
        }

        lazyMonitor.applyMutations(mutations, to: storage)

        let expectedMutations = [
            TextMutation(string: "1", range: NSRange(3..<3), limit: 3),
            TextMutation(string: "", range: NSRange(1..<2), limit: 4),
        ]

        XCTAssertEqual(visibleMutations, expectedMutations)
    }

    func testNeedsToProcessMutation() {
        let mockMonitor = MockTextStoringMonitor()
        let storage = NSTextStorage(string: "abcdefghi")

        let lazyMonitor = LazyTextStoringMonitor(storingMonitor: mockMonitor)
        lazyMonitor.minimumDelta = 3

        lazyMonitor.ensureTextProcessed(upTo: 3, in: storage)

        lazyMonitor.ignoreUnprocessedMutations = true

        XCTAssertTrue(lazyMonitor.needsToProcessMutation(in: NSRange(0..<0)))
        XCTAssertTrue(lazyMonitor.needsToProcessMutation(in: NSRange(0..<1)))
        XCTAssertTrue(lazyMonitor.needsToProcessMutation(in: NSRange(0..<4)))
        XCTAssertTrue(lazyMonitor.needsToProcessMutation(in: NSRange(3..<3)))
        XCTAssertFalse(lazyMonitor.needsToProcessMutation(in: NSRange(4..<4)))
    }

    func testDeleteAfterFullyProcessed() {
        let mockMonitor = MockTextStoringMonitor()
        let storage = NSTextStorage(string: "abcdefghi")

        let lazyMonitor = LazyTextStoringMonitor(storingMonitor: mockMonitor)

        lazyMonitor.ensureAllTextProcessed(for: storage)

        let mutation = TextMutation(string: "", range: NSRange(3..<6), limit: 9)

        lazyMonitor.applyMutation(mutation, to: storage)
    }
}
