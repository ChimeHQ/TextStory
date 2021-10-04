import Foundation
import TextStory

public class MockTextStoringMonitor: TextStoringMonitor {
    public var willApplyBlock: ((TextMutation, TextStoring) -> Void)?
    public var didApplyBlock: ((TextMutation, TextStoring, @escaping () -> Void) -> Void)
    public var didCompleteChangeBlock: ((TextMutation?, TextStoring) -> Void)?

    public init() {
        self.willApplyBlock = nil
        self.didApplyBlock = { (_, _, handler) in handler() }
        self.didCompleteChangeBlock = nil
    }

    public func willApplyMutation(_ mutation: TextMutation, to buffer: TextStoring) {
        willApplyBlock?(mutation, buffer)
    }

    public func didApplyMutation(_ mutation: TextMutation, to buffer: TextStoring, completionHandler: @escaping () -> Void) {
        didApplyBlock(mutation, buffer, completionHandler)
    }

    public func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        didCompleteChangeBlock?(mutation, storage)
    }
}
