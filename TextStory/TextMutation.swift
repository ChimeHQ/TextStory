import Foundation
import Rearrange

public struct TextMutation {
    public let string: String
    public let range: NSRange
    public let limit: Int

    public init(string: String, range: NSRange, limit: Int) {
        self.string = string
        self.range = range
        self.limit = limit
    }
}

extension TextMutation: Hashable {
}

public extension TextMutation {
    private var stringLength: Int {
        return string.utf16.count
    }

    var delta: Int {
        return stringLength - range.length
    }

    var rangeMutation: RangeMutation {
        return RangeMutation(range: range, delta: delta, limit: limit)
    }

    var inverseDelta: Int {
        return range.length - stringLength
    }

    var inverseRange: NSRange {
        return NSRange(location: range.location, length: stringLength)
    }

    /// The range this mutation represents in the target after it has been applied
    var postApplyRange: NSRange {
        let start = range.location
        let end = range.max + delta

        return NSRange(start..<end)
    }
}
