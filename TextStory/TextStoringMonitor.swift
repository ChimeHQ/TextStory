import Foundation

public protocol TextStoringMonitor {
    func willApplyMutation(_ mutation: TextMutation, to storage: TextStoring)
    func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring, completionHandler: @escaping () -> Void)
    func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring)
}

public extension TextStoringMonitor {
    func processMutation(_ mutation: TextMutation, in storage: TextStoring, completionHandler: @escaping () -> Void = {}) {
        willApplyMutation(mutation, to: storage)
        didApplyMutation(mutation, to: storage, completionHandler: completionHandler)
        didCompleteChangeProcessing(of: mutation, in: storage)
    }
}
