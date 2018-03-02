//
//  NatsSubject.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

struct NatsSubject {
    
    let subject: String
    let id: String
    
    init(subject: String, id: String) {
        self.subject = subject
        self.id = id
    }
    
    init(subject: String) {
        let id = UUID().uuidString
        self.init(subject: subject, id: id)
    }
    
}

extension NatsSubject: Hashable {
    static func ==(lhs: NatsSubject, rhs: NatsSubject) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    var hashValue: Int {
        return self.id.hashValue
    }
}
