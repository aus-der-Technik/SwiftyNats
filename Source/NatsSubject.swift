//
//  NatsSubject.swift
//  SwiftyNatsPackageDescription
//
//  Created by Ray Krow on 2/27/18.
//


struct NatsSubject {
    
    let subject: String
    let id: String
    
    init(subject: String, id: String) {
        self.subject = subject
        self.id = id
    }
    
    init(subject: String) {
        let id = "a random new id"
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
