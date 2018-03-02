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
        
        self.sendMessage("SUB \(subject.subject) \(subject.id)")
        
        self.subjectHandlerStore[subject] = handler
        
        return subject
    }
    
    public func unsubscribe(fromSubject subject: NatsSubject) {
        
        self.sendMessage("UNSUB \(subject.id)")
        self.subjectHandlerStore[subject] = nil
        
    }
    
    // MARK - Implement Private Methods
    
    func handleIncomingMessage(_ messageStr: String) {
        
        guard let message = parseMessage(messageStr) else { return }
        
        guard let handler = self.subjectHandlerStore[message.subject] else { return }
        
        print("DEBUG -> Calling handler")
        handler(message)
    }
    
    func parseMessage(_ message: String) -> NatsMessage? {
        let components = message.components(separatedBy: CharacterSet.newlines).filter { !$0.isEmpty }
        
        if components.count <= 0 { return nil }
        
        let payload = components[1]
        let header = components[0]
            .removePrefix(NatsOperation.message.rawValue)
            .components(separatedBy: CharacterSet.whitespaces)
            .filter { !$0.isEmpty }
        
        let subject: String
        let sid: String
        let byteCount: UInt32?
        let replySubject: String?
        
        switch (header.count) {
        case 3:
            subject = header[0]
            sid = header[1]
            byteCount = UInt32(header[2])
            replySubject = nil
            break
        case 4:
            subject = header[0]
            sid = header[1]
            replySubject = nil
            byteCount = UInt32(header[3])
            break
        default:
            return nil
        }
        
        return NatsMessage(
            payload: payload,
            byteCount: byteCount,
            subject: NatsSubject(subject: subject, id: sid),
            replySubject: replySubject == nil ? nil : NatsSubject(subject: replySubject!)
        )
    }

    
}
