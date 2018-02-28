//
//  Data+String.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//
import Foundation

extension Data {
    func toString() -> String? {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
    }
}
