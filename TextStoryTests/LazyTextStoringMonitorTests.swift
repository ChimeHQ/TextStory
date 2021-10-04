import XCTest
import TextStory
import TextStoryTesting

final class LazyTextStoringMontiorTests: XCTestCase {
    func testEnsuresProcessingForMutation() {
        let mockMonitor = MockTextStoringMonitor()
        let storage = NSTextStorage(string: "abcdef")

        let lazyMonitor = LazyTextStoringMonitor(storingMonitor: mockMonitor)
        lazyMonitor.minimumDelta = 3

        var mutations: [TextMutation] = []

        let willApplyExpectation = XCTestExpectation(description: "willApply")
        willApplyExpectation.expectedFulfillmentCount = 2
        mockMonitor.willApplyBlock = { (mutation, _) in
            mutations.append(mutation)

            willApplyExpectation.fulfill()
        }

        let didApplyExpectation = XCTestExpectation(description: "didApply")
        didApplyExpectation.expectedFulfillmentCount = 2
        mockMonitor.didApplyBlock = { (mutation, _, completionHandler) in
            XCTAssertEqual(mutation, mutations.last)

            didApplyExpectation.fulfill()

            completionHandler()
        }

        let mutation = TextMutation(string: "gh", range: NSRange(location: 6, length: 0), limit: 6)

        lazyMonitor.willApplyMutation(mutation, to: storage)

        wait(for: [willApplyExpectation], timeout: 0.1)

        let expectedMutations = [
            TextMutation(string: "abcdef", range: NSRange.zero, limit: 0),
            mutation
        ]

        XCTAssertEqual(mutations, expectedMutations)

        storage.applyMutation(mutation)
        XCTAssertEqual(storage.string, "abcdefgh")

        lazyMonitor.didApplyMutation(mutation, to: storage, completionHandler: {})

        wait(for: [didApplyExpectation], timeout: 0.1)

        XCTAssertEqual(mutations, expectedMutations)
    }
}
