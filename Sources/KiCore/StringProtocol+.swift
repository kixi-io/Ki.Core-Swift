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
    
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
    
    subscript(_ index:Int) -> Character {
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: Swift.max(0, range.lowerBound))
        let end = index(start, offsetBy: Swift.min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: Swift.max(0, range.lowerBound))
        let end = index(start, offsetBy: Swift.min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start...end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: Swift.max(0, range.lowerBound))
         return String(self[start...])
    }
    
    func removePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self as? String ?? self.description }
        return String(self.dropFirst(prefix.count))
    }
    
    func removeSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self as? String ?? self.description }
        return String(self.dropLast(suffix.count))
    }
    
    /**
     * Resolve escapes within a string. For example, the text `\t` will be converted into a
     * tab. This also handles unicode escapes in the form `\uxxxx`, where `x` is a
     * hexidecimal digit.
     */
    func resolveEscapes(quoteChar: Character? = "\"") throws -> String {
        var escape = false
        var sb = ""

        var index = 0

        outer: while(index<count) {

            let c = chars[index]

            if(escape) {
                switch(c) {
                    case "t": sb.append("\t")
                    case "r": sb.append("\r")
                    case "n": sb.append("\n")
                    case "u":
                        if count < index + 5 {
                                throw ParseError(
                                    """
                                    Unicode escape requires four hexidecimal
                                    digits. Got \(self[index...]))
                                    """
                                )
                        }
                        index+=1
                        let hexDigits = self[index..<index+4]
                        let charInt = Int(hexDigits, radix: 16)
                        if(charInt == nil) {
                            throw ParseError("Invalid hex code in \\u escape \(hexDigits)", index:index)
                        }
                        
                        let scalar = UnicodeScalar(charInt!)
                        if(scalar == nil) {
                            throw ParseError("Invalid unicode escape \(hexDigits)", index:index)
                        }
                        
                        sb.append(String(scalar!))

                        index+=4
                        escape = false
                        continue outer
                    case "\\": sb.append("\\")
                    case quoteChar: if quoteChar != nil { sb.append(quoteChar!) }
                    default: throw ParseError("Invalid escape char \(c)")
                }
                escape = false
            } else if(c=="\\") {
                escape = true
            } else {
                sb.append(c)
            }
            index += 1
        }

        return (quoteChar == nil) ? sb : sb.description.replaceAll("\\\(String(describing: quoteChar))",
                                                                   "\(String(describing: quoteChar))")
    }
}


