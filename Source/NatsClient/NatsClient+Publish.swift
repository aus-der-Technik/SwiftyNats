//
//  NatsClient+Publish.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsPublish {
    
    // MARK - Implement NatsPublish Protocol
    
    open func publish(_ payload: String, to subject: String) {
        sendMessage(NatsMessage.publish(payload: payload, subject: subject))
    }
    
    open func publish(_ payload: String, to subject: NatsSubject) {
        publish(payload, to: subject.subject)
    }
    
    open func reply(toMessage message: NatsMessage, withPayload payload: String) {
        guard let replySubject = message.replySubject else { return }
        publish(payload, to: replySubject.subject)
    }
    
    open func publishAsync(_ payload: String, to subject: String) throws {
        
        let group = DispatchGroup()
        group.enter()
        
        var error: NatsPublishError?
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            // Wait for server to respond with +OK
            guard let s = self else { group.leave(); return }
            s.on(.response) { event in
                if event == .error {
                    error = NatsPublishError("Nats server had an error while publishing our message")
                }
                group.leave()
            }
        }
        
        publish(payload, to: subject)
        
        group.wait()
        
        if let e = error {
            throw e
        }
        
    }
    
    open func publishAsync(_ payload: String, to subject: NatsSubject) throws {
        try publishAsync(payload, to: subject.subject)
    }
    
    open func replyAsync(toMessage message: NatsMessage, withPayload payload: String) throws {
        guard let replySubject = message.replySubject else { return }
        try publishAsync(payload, to: replySubject.subject)
    }
    
}
