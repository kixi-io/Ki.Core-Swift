//
//  File.swift
//  
//
//  Created by Daniel LEUCK on 10/6/20.
//

import Foundation

public extension Array {
    
    func format(separator:String=", ", formatter:Formatter? = nil) -> String {
        var text = ""
        
        if !self.isEmpty {
            for index in 0...self.count-1 {
                if formatter != nil {
                    text+="\(formatter!.string(for:self[index]) ?? String(describing:self[index]))"
                } else {
                    text+=("\(self[index])")
                }
                if(index<count-1) {
                    text+=separator
                }
            }
        }
        return text
    }
}

