//
//  String+Utilities.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension String {
    
    func removeNewlines() -> String {
        return self.components(separatedBy: CharacterSet.newlines).reduce("", {$0 + $1})
    }
    
    func removePrefix(_ prefix: String) -> String {
        let index = self.index(self.startIndex, offsetBy: prefix.count)
        return String(self[index...])
    }
    
    func toJsonDicitonary() -> [String: AnyObject]? {
        
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        
        return obj as? [String: AnyObject]
    }
    
}
