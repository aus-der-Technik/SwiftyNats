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
    
    open func unsubscribeSync(from subject: NatsSubject) throws {
        
        let group = DispatchGroup()
        group.enter()
        
        var error: NatsSubscribeError?
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            // Wait for server to respond with +OK
            guard let s = self else { group.leave(); return }
            s.on(.response) { event in
                if event == .error {
                    error = NatsSubscribeError("Nats server rejected our request to unsubscribe")
                }
                group.leave()
            }
        }
        
        self.sendMessage(NatsMessage.unsubscribe(sid: subject.id))
        
        group.wait()
        
        if let e = error {
            throw e
        }
        
        self.subjectHandlerStore[subject] = nil
        
    }
    
    open func subscribeSync(to subject: String, _ handler: @escaping (NatsMessage) -> Void) throws -> NatsSubject {
        
        let group = DispatchGroup()
        group.enter()
        
        var error: NatsSubscribeError?
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            // Wait for server to respond with +OK
            guard let s = self else { group.leave(); return }
            s.on([.response, .error]) { event in
                if event == .error {
                    error = NatsSubscribeError("Nats server rejected our request to subscribe to \(subject)")
                }
                group.leave()
            }
        }
        
        let nsub = NatsSubject(subject: subject)
        self.sendMessage(NatsMessage.subscribe(subject: nsub.subject, sid: nsub.id))
        
        group.wait()
        
        if let e = error {
            throw e
        }
        
        self.subjectHandlerStore[nsub] = handler
        
        return nsub
        
    }
    
}
