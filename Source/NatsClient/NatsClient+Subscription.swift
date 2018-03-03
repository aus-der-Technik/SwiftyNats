//
//  NatsClient+Subscription.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsSubscription {
    
    // MARK - Implement NatsSubscription Protocol
    
    public func subscribe(toSubject subjectName: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject {
        
        let subject = NatsSubject(subject: subjectName)
        
        self.sendMessage(NatsMessage.subscribe(subject: subject.subject, sid: subject.id))
        
        self.subjectHandlerStore[subject] = handler
        
        return subject
    }
    
    public func unsubscribe(fromSubject subject: NatsSubject) {
        
        self.sendMessage(NatsMessage.unsubscribe(sid: subject.id))
        self.subjectHandlerStore[subject] = nil
        
    }
    
}
