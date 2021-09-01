//
//  NatsSubject.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//  updated by aus der Technik, 2021
//

import Foundation

public struct NatsSubject {
    
    let subject: String
    let id: String
    
    public var description: String {
        get {
            return subject
        }
    }
    
    init(subject: String, id: String) {
        self.subject = subject
        self.id = id
    }
    
    init(subject: String) {
        let id = String.hash()
        self.init(subject: subject, id: id)
    }
    
    
}

extension NatsSubject: Hashable {
    public static func ==(lhs: NatsSubject, rhs: NatsSubject) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id.hashValue)
    }
}

