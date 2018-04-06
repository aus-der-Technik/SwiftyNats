//
//  Data+String.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension Data {
    func toString() -> String? {
        guard let nss = NSString(data: self, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return String(describing: nss)
    }
}
