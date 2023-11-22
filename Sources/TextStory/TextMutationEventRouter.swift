import Foundation

/// Routes `TSYTextStorageDelegate` calls to multiple `TextStoringMonitor` instances
///
/// This class can except all the `TSYTextStorageDelegate` calls and forward them
/// to multiple `TextStoringMonitor` instances. While it can be directly assigned
/// as the `storageDelegate` of `TSYTextStorageDelegate`, that could potentially be
/// inconvenient for your usage. In that case, just forward along the calls.
public final class TextMutationEventRouter: NSObject {
	private var internalMonitor = CompositeTextStoringMonitor(monitors: [])
    public var storingMonitorsCompletionBlock: ((TextStoring) -> Void)?
    public private(set) var pendingMutation: TextMutation?

	public override init() {
    }

    public var processingTextChange: Bool {
        return pendingMutation != nil
    }

	public var storingMonitors: [TextStoringMonitor] {
		get { internalMonitor.monitors }
		set { internalMonitor.monitors = newValue }
	}
}

extension TextMutationEventRouter: TSYTextStorageDelegate {
    public func textStorage(_ textStorage: TSYTextStorage, willReplaceCharactersIn range: NSRange, with string: String) {
		precondition(processingTextChange == false, "Must not be processing a text change when another is begun")
			
		let mutation = TextMutation(string: string, range: range, limit: textStorage.length)
			
		self.pendingMutation = mutation
			
		internalMonitor.willApplyMutation(mutation, to: textStorage)
    }

    public func textStorage(_ textStorage: TSYTextStorage, didReplaceCharactersIn range: NSRange, with string: String) {
        // it's necessary to recreate the limit, because at this point the storage has changed,
        // and the length has now been modified
        let delta = string.utf16.count - range.length
        let preeditLimit = textStorage.length - delta

        let mutation = TextMutation(string: string, range: range, limit: preeditLimit)

		precondition(mutation == pendingMutation, "Pre and post mutations must be the same")
			
		internalMonitor.didApplyMutation(mutation, to: textStorage)
    }

    public func textStorageWillCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
		internalMonitor.willCompleteChangeProcessing(of: pendingMutation, in: textStorage)
    }

    public func textStorageDidCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
		internalMonitor.didCompleteChangeProcessing(of: pendingMutation, in: textStorage)

		pendingMutation = nil
    }
}
