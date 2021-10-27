import Foundation

public class LazyTextStoringMonitor {
    public let storingMonitor: TextStoringMonitor
    public private(set) var maximumProcessedLocation: Int
    public var minimumDelta: UInt = 1024
    public var ignoreUnprocessedMutations = false

    public init(storingMonitor: TextStoringMonitor) {
        self.storingMonitor = storingMonitor
        self.maximumProcessedLocation = 0
    }

    public func needsToProcessMutation(in range: NSRange) -> Bool {
        guard ignoreUnprocessedMutations else {
            return true
        }

        return range.location <= maximumProcessedLocation
    }
}

extension LazyTextStoringMonitor: TextStoringMonitor {
    public func willApplyMutation(_ mutation: TextMutation, to storage: TextStoring) {
        if needsToProcessMutation(in: mutation.range) == false {
            return
        }

        ensureTextProcessed(upTo: mutation.range.max, in: storage)

        storingMonitor.willApplyMutation(mutation, to: storage)
    }

    public func didApplyMutation(_ mutation: TextMutation, to storage: TextStoring, completionHandler: @escaping () -> Void) {
        if needsToProcessMutation(in: mutation.range) == false {
            return
        }

        adjustMaximum(with: mutation, in: storage)

        storingMonitor.didApplyMutation(mutation, to: storage, completionHandler: completionHandler)
    }

    public func didCompleteChangeProcessing(of mutation: TextMutation?, in storage: TextStoring) {
        if let mutation = mutation, needsToProcessMutation(in: mutation.range) == false {
            return
        }

        storingMonitor.didCompleteChangeProcessing(of: mutation, in: storage)
    }
}

extension LazyTextStoringMonitor {
    private func adjustMaximum(with mutation: TextMutation, in storage: TextStoring) {
        precondition(maximumProcessedLocation <= mutation.limit)

        maximumProcessedLocation += mutation.delta

        precondition(maximumProcessedLocation >= 0)
        precondition(maximumProcessedLocation <= storage.length)
    }

    public func ensureTextProcessed(including location: Int, in storage: TextStoring) {
        precondition(location <= storage.length)
        
        let actualLoc = min(location + 1, storage.length)

        ensureTextProcessed(upTo: actualLoc, in: storage)
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

        storingMonitor.processMutation(mutation, in: storage)
        adjustMaximum(with: mutation, in: storage)
    }

    public func ensureAllTextProcessed(for storage: TextStoring) {
        ensureTextProcessed(upTo: storage.length, in: storage)
    }
}
