//
//  StringProtocol+.swift
//
//  Created by Daniel LEUCK on 12/3/19.
//

// Note: This includes code in a response by Kevin R on StackOverflow:
// https://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji

import Foundation

public extension StringProtocol {
    
    func before(_ substring:CustomStringConvertible) -> String? {
        if substring is Character {
            let firstIdx = firstIndex(of: substring as! Character)
            return firstIdx==nil ? nil : String(self[..<firstIdx!])
        }
        
        let sub = substring is String ? substring as! String : substring.description
        
        if let range = description.range(of: sub) {
            return String(self[..<range.lowerBound])
        }
        
        return nil
    }
    
    func beforeLast(_ substring:CustomStringConvertible) -> String? {
        if substring is Character {
            let lastIdx = lastIndex(of: substring as! Character)
            return lastIdx==nil ? nil : String(self[..<lastIdx!])
        }
        
        let sub = substring is String ? substring as! String : substring.description
        
        if let range = description.range(of: sub, options:NSString.CompareOptions.backwards) {
            return String(self[..<range.lowerBound])
        }
        
        return nil
    }
    
    ////
    
    func after(_ substring:CustomStringConvertible) -> String? {
        if substring is Character {
            let firstIdx = firstIndex(of: substring as! Character)
            
            return firstIdx==nil ? nil : String(self[index(after: firstIdx!)...])
        }
        
        let sub = substring is String ? substring as! String : substring.description
        
        if let range = description.range(of: sub) {
            return String(self[range.upperBound...])
        }
        
        return nil
    }
    
    func afterLast(_ substring:CustomStringConvertible) -> String? {
        if substring is Character {
            let lastIdx = lastIndex(of: substring as! Character)
            
            return lastIdx==nil ? nil : String(self[index(after: lastIdx!)...])
        }
        
        let sub = substring is String ? substring as! String : substring.description
        
        if let range = description.range(of: sub, options:NSString.CompareOptions.backwards) {
            return String(self[range.upperBound...])
        }
        
        return nil
    }
    
    var chars: [Character] {
       return self.map { $0 }
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func replaceAll(_ oldString:String, _ newString:String) -> String {
        return replacingOccurrences(of: oldString, with: newString)
    }
    
    func removeAll(_ string:String) -> String {
        return replaceAll(string, "")
    }
    
    func count(_ char: Character) -> Int {
        return filter { $0 == char }.count
    }
    
    // Indexes
    
    func index(_ string: CustomStringConvertible, options: String.CompareOptions = []) -> Index? {
        return range(of: string.description, options: options)?.lowerBound
    }
    
    func indexEnd(_ string: CustomStringConvertible, options: String.CompareOptions = [])
        -> Index? {
        return range(of: string.description, options: options)?.upperBound
    }
    
    func lastIndex(_ string: CustomStringConvertible) -> Index? {
        return range(of: string.description, options: .backwards)?.lowerBound
    }
    
    func lastIndexEnd(_ string: CustomStringConvertible) -> Index? {
        return range(of: string.description, options: .backwards)?.upperBound
    }
    
    // Emoji related properties

    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }

    var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }

    var emojis: [Character] {
        return filter { $0.isEmoji }
    }

    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
    
}


