//
//  TextStoring.swift
//  TextBase
//
//  Created by Matt Massicotte on 2019-12-16.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

public protocol TextStoring {
    var length: Int { get }

    func substring(from range: NSRange) -> String?

    func applyMutation(_ mutation: TextMutation)
}

public extension TextStoring {
    func replaceString(in range: NSRange, with string: String) {
        let mutation = TextMutation(string: string, range: range, limit: length)

        applyMutation(mutation)
    }

    func insertString(_ string: String, at location: Int) {
        let range = NSRange(location: location, length: 0)
        let mutation = TextMutation(string: string, range: range, limit: length)

        applyMutation(mutation)
    }

    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }

    var string: String {
        guard let str = substring(from: fullRange) else {
            fatalError("unablet to produce a substring using the full range")
        }

        return str
    }
}

public extension TextStoring {
    func inverseMutation(for mutation: TextMutation) -> TextMutation {
        guard let originalString = substring(from: mutation.range) else {
            fatalError("Range invalid for string")
        }

        let delta = mutation.inverseDelta
        let newRange = mutation.inverseRange
        let limit = length - delta

        return TextMutation(string: originalString, range: newRange, limit: limit)
    }
}
