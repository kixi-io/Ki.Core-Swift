// Duration+.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

extension Duration {
    
    /// Formats this Duration as a Ki literal string.
    ///
    /// - Parameter zeroPad: If true, zero-pad time components to 2 digits (e.g., "01:05:03")
    /// - Returns: The Ki literal representation of this duration
    /// - SeeAlso: `Ki.formatDuration`
    public func kiFormat(zeroPad: Bool = false) -> String {
        Ki.formatDuration(self, zeroPad: zeroPad)
    }
}
