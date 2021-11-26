import Foundation
import TextStory

public class MockTextStoringMonitor: TextStoringMonitor {
    public var willApplyBlock: ((TextMutation, TextStoring) -> Void)?
    public var didApplyBlock: ((TextMutation, TextStoring) -> Void)?
    public var didCompleteChangeBlock: ((TextMutation?, TextStoring) -> Void)?
    public var willCompleteChangeBlock: ((TextMutation?, TextStoring) -> Void)?

    public init() {
        self.willApplyBlock = nil
        self.didApplyBlock = nil
        self.willCompleteChangeBlock = nil
        self.didCompleteChangeBlock = nil
    }

    public func willApplyMutation(_ mutation: TextMutation, to buffer: TextStoring) {
        willApplyBlock?(mutation, buffer)
    }

    public func didApplyMutation(_ mutation: TextMutation, to buffer: TextStoring) {
        didApplyBlock?(mutation, buffer)
    }

    public func willCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        willCompleteChangeBlock?(mutation, storage)
    }

    public func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        didCompleteChangeBlock?(mutation, storage)
    }
}
