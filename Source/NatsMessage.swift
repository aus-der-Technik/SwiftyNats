//
//  NatsMessage.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//


struct NatsMessage {
    
    let payload: String?
    let byteCount: UInt32?
    let subject: NatsSubject
    let replySubject: NatsSubject?
    
    init(payload: String?, byteCount: UInt32?, subject: NatsSubject, replySubject: NatsSubject? = nil) {
        self.payload = payload
        self.byteCount = byteCount
        self.subject = subject
        self.replySubject = replySubject
    }
    
}
