import Foundation

public extension TextStoring {
    func findPreceedingOccurrenceOfCharacter(in set: CharacterSet, from location: Int) -> Int? {
        var checkLoc = min(location - 1, length - 1)

        while true {
            if checkLoc < 0 {
                return 0
            }

            let range = NSRange(location: checkLoc, length: 1)

            guard let value = substring(from: range) else {
                fatalError()
            }

            if value.unicodeScalars.allSatisfy({ set.contains($0) }) {
                return checkLoc + 1
            }

            checkLoc -= 1
        }
    }

    func findStartOfLine(containing location: Int) -> Int {
        return findPreceedingOccurrenceOfCharacter(in: CharacterSet.newlines, from: location) ?? 0
    }

    func leadingRange(in range: NSRange, within set: CharacterSet) -> NSRange? {
        guard let string = substring(from: range) else {
            return nil
        }

        let invertedSet = set.inverted

        guard let stringRange = string.rangeOfCharacter(from: invertedSet) else {
            return range
        }

        let nonMatchingRange = NSRange(stringRange, in: string)

        assert(nonMatchingRange.location <= range.length)
        assert(nonMatchingRange.location >= 0)

        return NSRange(location: range.location, length: nonMatchingRange.location)
    }

    func trailingRange(in range: NSRange, within set: CharacterSet) -> NSRange? {
        guard let string = substring(from: range) else {
            return nil
        }

        let invertedSet = set.inverted

        guard let stringRange = string.rangeOfCharacter(from: invertedSet, options: [.backwards], range: nil) else {
            return range
        }

        let nonMatchingRange = NSRange(stringRange, in: string)

        assert(nonMatchingRange.max <= range.length)
        assert(nonMatchingRange.max >= 0)

        return NSRange(location: range.location + nonMatchingRange.max, length: range.length - nonMatchingRange.max)
    }
}

public extension TextStoring {
    func leadingWhitespaceRange(in range: NSRange) -> NSRange? {
        return leadingRange(in: range, within: .whitespaces)
    }

    func trailingWhitespaceRange(in range: NSRange) -> NSRange? {
        return trailingRange(in: range, within: .whitespaces)
    }

    func leadingWhitespaceRange(containing location: Int) -> NSRange? {
        let lineStartLocation = findStartOfLine(containing: location)

        return leadingRange(in: NSRange(lineStartLocation..<location), within: .whitespaces)
    }
}
