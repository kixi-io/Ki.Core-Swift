//
//  File.swift
//  
//
//  Created by Daniel LEUCK on 10/21/20.
//

open class ParseError : Error, CustomStringConvertible {

    let message:String
    let line:Int, index:Int
    
    /**
     - parameters:
       - message: A description of the error. Default: "Parse error"
       - line: The line in a multiline String (e.g. content of a text file), Default: -1 (no line)
       - index: The index within the current line, Default: -1 (no index)
     */
    public init(_ message:String = "Parse error", line:Int = -1, index:Int = -1) {
        self.message = message
        self.line = line
        self.index = index
    }
    
    public var description: String {
        var desc = message
        
        if line != -1 {
            desc += " line: \(line)"
            
            if index != -1 {
                desc += " index: \(index)"
            }
        } else {
            if index != -1 {
                desc += " index: \(index)"
            }
        }
        
        return desc
    }
}
