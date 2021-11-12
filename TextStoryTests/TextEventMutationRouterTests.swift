import XCTest
import TextStory
import TextStoryTesting

final class TextEventMutationRouterTests: XCTestCase {
    func testNormalMutationRouting() {
        let mockMonitor = MockTextStoringMonitor()
        let router = TextMutationEventRouter()
        let storage = TSYTextStorage(string: "")

        storage.storageDelegate = router
        router.storingMonitors = [mockMonitor]

        let mutation = TextMutation(string: "abc", range: NSRange(0..<0), limit: 0)

        let willApplyExpectation = XCTestExpectation(description: "willApply")
        mockMonitor.willApplyBlock = { (_, _) in
            willApplyExpectation.fulfill()
        }

        let didApplyExpectation = XCTestExpectation(description: "didApply")
        mockMonitor.didApplyBlock = { (_, _, block) in
            didApplyExpectation.fulfill()
            block()
        }

        let didCompleteExpectation = XCTestExpectation(description: "didComplete")
        mockMonitor.didCompleteChangeBlock = { (finishedMutation, _) in
            XCTAssertEqual(finishedMutation, mutation)
            didCompleteExpectation.fulfill()
        }

        storage.applyMutation(mutation)

        wait(for: [willApplyExpectation, didApplyExpectation, didCompleteExpectation],
                timeout: 2.0,
                enforceOrder: true)
    }
}
