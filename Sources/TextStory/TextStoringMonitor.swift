import Foundation

public protocol TextStoringMonitor {
	@MainActor
    func willApplyMutation(_ mutation: TextMutation, to storage: TextStoring)
	@MainActor
    func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring)
	@MainActor
    func willCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring)
	@MainActor
    func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring)
}

@MainActor
public extension TextStoringMonitor {
    /// Invoke all the monitoring methods in order
    func processMutation(_ mutation: TextMutation, in storage: TextStoring) {
        willApplyMutation(mutation, to: storage)
        didApplyMutation(mutation, to: storage)
        willCompleteChangeProcessing(of: mutation, in: storage)
        didCompleteChangeProcessing(of: mutation, in: storage)
    }

    /// Apply the mutation to storage, and invoke all monitoring methods
    func applyMutation(_ mutation: TextMutation, to storage: TextStoring) {
        willApplyMutation(mutation, to: storage)
        storage.applyMutation(mutation)
        didApplyMutation(mutation, to: storage)
        willCompleteChangeProcessing(of: mutation, in: storage)
        didCompleteChangeProcessing(of: mutation, in: storage)
    }

    /// Apply an array of mutations to storage, and invoke all monitoring methods
    func applyMutations(_ mutations: [TextMutation], to storage: TextStoring) {
        for mutation in mutations {
            applyMutation(mutation, to: storage)
        }
    }
}
