//
//  File.swift
//  
//
//  Created by Daniel LEUCK on 10/6/20.
//

import Foundation

public extension Dictionary {
    
    func format(kvSeparator:String="=", pairSeparator:String=", ",
                keyFormatter:Formatter? = nil, valueFormatter:Formatter? = nil, sorted:Bool = false) -> String {
        
        var text = ""

        if !self.isEmpty {
            var index = 0
            if sorted {
                let keys = self.keys.sorted { String(describing:$0) < String(describing:$1) }
                 
                for key in keys {
                    let value = self[key]
                    
                    let skey: String = (keyFormatter == nil) ? "\(key)" : keyFormatter!.string(for:key)
                        ?? String(describing:key)
                    let svalue: String  = (valueFormatter == nil) ? "\(String(describing: value))" :
                        valueFormatter!.string(for:value) ?? String(describing:value)
                    
                    text+=("\(skey)\(kvSeparator)\(svalue)")

                    if index != self.count-1 {
                        text+=pairSeparator
                    }
                    
                    index+=1
                }
            } else {
                for entry in self {
                    let key: String = (keyFormatter == nil) ? "\(entry.key)" : keyFormatter!.string(for:entry.key)
                        ?? String(describing:entry.key)
                    let value: String  = (valueFormatter == nil) ? "\(entry.value)" :
                        valueFormatter!.string(for:entry.value) ?? String(describing:entry.value)
                    
                    text+=("\(key)\(kvSeparator)\(value)")

                    if index != self.count-1 {
                        text+=pairSeparator
                    }
                    
                    index+=1
                }
            }
        } else {
            text+=kvSeparator
        }
        return text
    }
}

