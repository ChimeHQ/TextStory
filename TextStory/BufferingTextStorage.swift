//
//  BufferingTextStorage.swift
//  TextBase
//
//  Created by Matt Massicotte on 2019-12-16.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation
import Rearrange

#if SPM_BUILD
import Internal
#endif

public class BufferingTextStorage: TSYTextStorage {
    private var changeQueue: [TextMutation] = []

    // Defaulting buffering to disabled saves us work when first constructing
    // the object
    public var bufferingEnabled: Bool = false {
        didSet {
            clearBuffer()
        }
    }

    override open func replaceCharacters(in range: NSRange, with str: String) {
        if bufferingEnabled {
            let mutation = TextMutation(string: str, range: range, limit: length)
            let inverse = internalStorage.inverseMutation(for: mutation)

            changeQueue.insert(inverse, at: changeQueue.startIndex)
        }

        super.replaceCharacters(in: range, with: str)
    }
}

extension BufferingTextStorage {
    public func clearBuffer() {
        changeQueue.removeAll(keepingCapacity: true)
    }

    public var changeCount: Int {
        return changeQueue.count
    }

    public func applyNextChange() {
        precondition(changeQueue.count > 0)
        precondition(bufferingEnabled)

        // because our concept of
        _ = changeQueue.removeLast()
    }

    public var bufferedLength: Int {
        precondition(bufferingEnabled)

        let sum = changeQueue.reduce(0, { $0 + $1.delta })

        let total = internalStorage.length + sum

        precondition(total >= 0)

        return total
    }

    public func bufferedSubstring(from range: NSRange) -> String {
        precondition(bufferingEnabled)

        // It seems obvious to use the NSMutableAttributedString(attributedString:) constructor,
        // but that was causing crashes internally in NSMutableAttributedString. Got tired of
        // debugging.

        let substringRange = minimumSubstringRange(for: range)
        let offset = -1 * substringRange.location

        let substring = internalStorage.attributedSubstring(from: substringRange).string
        let mutableString = NSMutableAttributedString(string: substring)

        for change in changeQueue {
            let shiftedRange = change.range.shifted(by: offset)!

            mutableString.replaceCharacters(in: shiftedRange, with: change.string)
        }

        return mutableString.attributedSubstring(from: range.shifted(by: offset)!).string
    }

    private func minimumSubstringRange(for range: NSRange) -> NSRange {
        var start = internalStorage.length
        var end = 0
        var delta = 0

        for change in changeQueue {
            start = min(start, change.range.location)
            end = max(end, change.range.max + delta)

            delta += change.inverseDelta
        }

        start = min(start, range.location)
        end = max(end, range.max + delta)

        precondition(start >= 0)
        precondition(end <= internalStorage.length)
        precondition(end >= start)

        return NSRange(start..<end)
    }

    public func transformBaseRange(_ range: NSRange) -> NSRange? {
        precondition(bufferingEnabled)

        var transformedRange = range

        // transforming a range from the base involves
        // inversing all of the queued changes, in reverse
        // order
        for change in changeQueue.reversed() {
            let inverseDelta = change.inverseDelta
            let inverseRange = change.inverseRange

            // note that enforcing limit checking here is really tough, because
            // during our transformations, the base range might end up outside the
            // current bounds
            let mutation = RangeMutation(range: inverseRange, delta: inverseDelta)

            guard let newRange = mutation.transform(range: transformedRange) else {
                return nil
            }

            transformedRange = newRange
        }

        return transformedRange
    }
}
