//
//  NatsClient+Subscribe.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsSubscribe {
    
    // MARK - Implement NatsSubscribe Protocol
    
    @discardableResult
    open func subscribe(to subject: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject {
        
        let nsub = NatsSubject(subject: subject)
        
        self.sendMessage(NatsMessage.subscribe(subject: nsub.subject, sid: nsub.id))
        
        self.subjectHandlerStore[nsub] = handler
        
        return nsub
    }
    
    @discardableResult
    open func subscribe(to subject: String, asPartOf queue: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject {
        
        let nsub = NatsSubject(subject: subject)
        
        self.sendMessage(NatsMessage.subscribe(subject: nsub.subject, sid: nsub.id, queue: queue))
        
        self.subjectHandlerStore[nsub] = handler
        
        return nsub
        
    }
    
    open func unsubscribe(from subject: NatsSubject) {
        
        self.sendMessage(NatsMessage.unsubscribe(sid: subject.id))
        self.subjectHandlerStore[subject] = nil
        
    }
    
    open func unsubscribeSync(from subject: NatsSubject) throws {
        
        let group = DispatchGroup()
        group.enter()
        
        var response: NatsEvent?
        
        self.on([.response, .error], autoOff: true) { e in
            response = e
            group.leave()
        }
        
        self.sendMessage(NatsMessage.unsubscribe(sid: subject.id))
        
        group.wait()
        
        if response == .error {
            throw NatsSubscribeError("Error response from server")
        }
        
        self.subjectHandlerStore[subject] = nil
        
    }
    
    @discardableResult
    open func subscribeSync(to subject: String, _ handler: @escaping (NatsMessage) -> Void) throws -> NatsSubject {
        return try subSync(to: subject, asPartOf: "", handler)
    }
    
    @discardableResult
    open func subscribeSync(to subject: String, asPartOf queue: String, _ handler: @escaping (NatsMessage) -> Void) throws -> NatsSubject {
        return try subSync(to: subject, asPartOf: queue, handler)
    }
    
    // MARK - Private methods
    
    private func subSync(to subject: String, asPartOf queue: String, _ handler: @escaping (NatsMessage) -> Void) throws -> NatsSubject {
     
        let group = DispatchGroup()
        group.enter()
        
        var response: NatsEvent?
        
        self.on([.response, .error], autoOff: true) { e in
            response = e
            group.leave()
        }
        
        let nsub = NatsSubject(subject: subject)
        self.sendMessage(NatsMessage.subscribe(subject: nsub.subject, sid: nsub.id))
        
        group.wait()
        
        if response == .error {
            throw NatsSubscribeError("Error response from server")
        }
        
        self.subjectHandlerStore[nsub] = handler
        
        return nsub
        
    }
    
}
