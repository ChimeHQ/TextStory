import Foundation

public class LazyTextStoringMonitor {
    public let storingMonitor: TextStoringMonitor
    public private(set) var maximumProcessedLocation: Int
    public var minimumDelta: UInt = 1024

    public init(storingMonitor: TextStoringMonitor) {
        self.storingMonitor = storingMonitor
        self.maximumProcessedLocation = 0
    }
}

extension LazyTextStoringMonitor: TextStoringMonitor {
    public func willApplyMutation(_ mutation: TextMutation, to storage: TextStoring) {
        ensureTextProcessed(upTo: mutation.range.max, in: storage)

        storingMonitor.willApplyMutation(mutation, to: storage)
    }

    public func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring, completionHandler: @escaping () -> Void) {
        adjustMaximum(with: mutation, in: storage)

        storingMonitor.didApplyMutation(mutation, to: storage, completionHandler: completionHandler)
    }

    public func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        storingMonitor.didCompleteChangeProcessing(of: mutation, in: storage)
    }
}

extension LazyTextStoringMonitor {
    private func adjustMaximum(with mutation: TextMutation, in storage: TextStoring) {
        precondition(maximumProcessedLocation <= mutation.limit)

        maximumProcessedLocation += maximumProcessedLocation

        precondition(maximumProcessedLocation >= 0)
        precondition(maximumProcessedLocation <= storage.length)
    }

    public func ensureTextProcessed(upTo location: Int, in storage: TextStoring) {
        let start = maximumProcessedLocation
        let delta = location - start
        let limit = storage.length

        precondition(location <= limit)
        precondition(start <= limit)

        if delta <= 0 {
            return
        }

        // We're going to simulate a mutation, to progressively expose the contents
        // to our monitor.
        //
        // First, see how much further we need to go
        let usableDelta = max(delta, Int(minimumDelta))
        let maxLocation = min(start + usableDelta, limit)

        // Then, prepare the mutation
        let newRange = NSRange(start..<maxLocation)
        guard let substring = storage.substring(from: newRange) else {
            fatalError("Unable to compute progressive substring")
        }
        let insertionRange = NSRange(location: start, length: 0)

        // This is a little subtle. The limit here represents the maximum we've
        // revealed so far to the underlying monitor.
        let mutation = TextMutation(string: substring, range: insertionRange, limit: start)

        processMutation(mutation, in: storage)
    }

    public func ensureAllTextProcessed(for storage: TextStoring) {
        ensureTextProcessed(upTo: storage.length, in: storage)
    }
}
