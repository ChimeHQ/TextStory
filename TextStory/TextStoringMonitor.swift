import Foundation

public protocol TextStoringMonitor {
    func willApplyMutation(_ mutation: TextMutation, to storage: TextStoring)
    func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring)
    func willCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring)
    func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring)
}

public extension TextStoringMonitor {
    func processMutation(_ mutation: TextMutation, in storage: TextStoring) {
        willApplyMutation(mutation, to: storage)
        didApplyMutation(mutation, to: storage)
        willCompleteChangeProcessing(of: mutation, in: storage)
        didCompleteChangeProcessing(of: mutation, in: storage)
    }
}
