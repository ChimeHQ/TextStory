import Foundation

public struct CompositeTextStoringMonitor {
    public var monitors: [TextStoringMonitor]
    private var queue: DispatchQueue

    public init(monitors: [TextStoringMonitor], queue: DispatchQueue = DispatchQueue.main) {
        self.monitors = monitors
        self.queue = queue
    }
}

extension CompositeTextStoringMonitor: TextStoringMonitor {
    public func willApplyMutation(_ mutation: TextMutation, to storage: TextStoring) {
        monitors.forEach({ $0.willApplyMutation(mutation, to: storage) })
    }

    public func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring) {
        monitors.forEach({ $0.didApplyMutation(mutation, to: storage) })
    }

    public func willCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        monitors.forEach({ $0.willCompleteChangeProcessing(of: mutation, in: storage) })
    }

    public func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        monitors.forEach({ $0.didCompleteChangeProcessing(of: mutation, in: storage) })
    }
}
