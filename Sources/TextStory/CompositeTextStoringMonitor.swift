import Foundation

/// Fans out `TextStoringMonitor` notitications to mulitple other monitors.
public struct CompositeTextStoringMonitor {
	public var monitors: [TextStoringMonitor]

	public init(monitors: [TextStoringMonitor]) {
		self.monitors = monitors
	}
}

extension CompositeTextStoringMonitor: TextStoringMonitor {
	public func willApplyMutation(_ mutation: TextMutation, to storage: TextStoring) {
		for monitor in monitors {
			monitor.willApplyMutation(mutation, to: storage)
		}
	}

	public func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring) {
		for monitor in monitors {
			monitor.didApplyMutation(mutation, to: storage)
		}
	}

	public func willCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
		for monitor in monitors {
			monitor.willCompleteChangeProcessing(of: mutation, in: storage)
		}
	}

	public func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
		for monitor in monitors {
			monitor.didCompleteChangeProcessing(of: mutation, in: storage)
		}
	}
}
