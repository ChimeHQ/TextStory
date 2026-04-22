//
//  NSTextStorage+TextStoring.swift
//  TextBase
//
//  Created by Matt Massicotte on 2019-12-16.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension NSTextStorage: TextStoring {
    public func applyMutation(_ mutation: TextMutation) {
        replaceCharacters(in: mutation.range, with: mutation.string)
    }

    public func substring(from range: NSRange) -> String? {
		if range.location < 0 || range.location == NSNotFound {
			return nil
		}

		if range.max > length {
            return nil
        }

        return (string as NSString).substring(with: range)
    }
}
