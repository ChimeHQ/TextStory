import Foundation

/// Routes `TSYTextStorageDelegate` calls to multiple `TextStoringMonitor` instances
///
/// This class can except all the `TSYTextStorageDelegate` calls and forward them
/// to multiple `TextStoringMonitor` instances. While it can be directly assigned
/// as the `storageDelegate` of `TSYTextStorageDelegate`, that could potentially be
/// inconvenient for your usage. In that case, just forward along the calls.
///
/// This class is only safe to use from the main thread.
public class TextMutationEventRouter: NSObject {
    public var storingMonitors: [TextStoringMonitor]
    public var storingMonitorsCompletionBlock: ((TextStoring) -> Void)?
    public private(set) var pendingMutation: TextMutation?

    public override init() {
        self.storingMonitors = []
        self.storingMonitorsCompletionBlock = nil

        super.init()
    }

    private func preconditionOnMainQueue() {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
    }

    public var processingTextChange: Bool {
        return pendingMutation != nil
    }
}

extension TextMutationEventRouter: TSYTextStorageDelegate {
    public func textStorage(_ textStorage: TSYTextStorage, willReplaceCharactersIn range: NSRange, with string: String) {
        preconditionOnMainQueue()
        precondition(processingTextChange == false, "Must not be processing a text change when another is begun")

        let mutation = TextMutation(string: string, range: range, limit: textStorage.length)

        self.pendingMutation = mutation

        for monitor in storingMonitors {
            monitor.willApplyMutation(mutation, to: textStorage)
        }
    }

    public func textStorage(_ textStorage: TSYTextStorage, didReplaceCharactersIn range: NSRange, with string: String) {
        preconditionOnMainQueue()

        // it's necessary to recreate the limit, because at this point the storage has changed,
        // and the length has now been modified
        let delta = string.utf16.count - range.length
        let preeditLimit = textStorage.length - delta

        let mutation = TextMutation(string: string, range: range, limit: preeditLimit)

        precondition(mutation == pendingMutation, "Pre and post mutations must be the same")

        notifyDidApplyMutationMonitors(mutation, with: textStorage)
        notifyWillCompleteChangeProcessing(of: mutation, for: textStorage)
    }

    public func textStorageProcessEditingComplete(_ textStorage: TSYTextStorage) {
        preconditionOnMainQueue()

        if pendingMutation == nil {
            // When there is no pending mutation, this method won't yet have been invoked. Do
            // that here so clients have a consistent experience
            notifyWillCompleteChangeProcessing(of: pendingMutation, for: textStorage)
        }

        let mutation = pendingMutation

        notifyDidCompleteChangeProcessing(of: mutation, for: textStorage)

        pendingMutation = nil
    }
}

extension TextMutationEventRouter {
    private func notifyDidApplyMutationMonitors(_ mutation: TextMutation, with storage: TextStoring) {
        let group = DispatchGroup()

        for monitor in storingMonitors {
            group.enter()
            monitor.didApplyMutation(mutation, to: storage) {
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main, execute: {
            self.storingMonitorsCompletionBlock?(storage)
        })
    }

    private func notifyWillCompleteChangeProcessing(of mutation: TextMutation?, for storage: TextStoring) {
        // when/if TextStoringMonitor can support this, here is where it would go
    }

    private func notifyDidCompleteChangeProcessing(of mutation: TextMutation?, for storage: TextStoring) {
        for monitor in storingMonitors {
            monitor.didCompleteChangeProcessing(of: mutation, in: storage)
        }
    }
}
