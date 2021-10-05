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

    public func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring, completionHandler: @escaping () -> Void) {
        let group = DispatchGroup()

        for monitor in monitors {
            group.enter()
            monitor.didApplyMutation(mutation, to: storage) {
                group.leave()
            }
        }

        group.notify(queue: queue, execute: {
            completionHandler()
        })
    }

    public func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        monitors.forEach({ $0.didCompleteChangeProcessing(of: mutation, in: storage) })
    }
}
