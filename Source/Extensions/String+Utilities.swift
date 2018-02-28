//
//  String+Utilities.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension String: Error { }

extension String {
    
    func flattenedMessage() -> String {
        return self.components(separatedBy: CharacterSet.newlines).reduce("", {$0 + $1})
    }
    
    func removePrefix(_ prefix: String) -> String {
        let index = self.index(self.startIndex, offsetBy: prefix.count)
        return String(self[..<index])
    }
    
    func convertToDictionary() -> [String: AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
}
