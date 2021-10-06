import XCTest
import TextStory
import TextStoryTesting

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
        mockMonitor.didApplyBlock = { (mutation, _, completionHandler) in
            XCTAssertEqual(mutation, appliedMutations.last)

            didApplyExpectation.fulfill()

            completionHandler()
        }

        for mutation in mutations {
            lazyMonitor.willApplyMutation(mutation, to: storage)
            storage.applyMutation(mutation)
            lazyMonitor.didApplyMutation(mutation, to: storage, completionHandler: {})
        }

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
}
