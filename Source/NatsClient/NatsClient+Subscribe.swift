//
//  NatsClient+Subscribe.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsSubscribe {
    
    // MARK - Implement NatsSubscribe Protocol
    
    open func subscribe(to subject: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject {
        
        let nsub = NatsSubject(subject: subject)
        
        self.sendMessage(NatsMessage.subscribe(subject: nsub.subject, sid: nsub.id))
        
        self.subjectHandlerStore[nsub] = handler
        
        return nsub
    }
    
    open func unsubscribe(from subject: NatsSubject) {
        
        self.sendMessage(NatsMessage.unsubscribe(sid: subject.id))
        self.subjectHandlerStore[subject] = nil
        
    }
    
}
