//
//  NatsMessage.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

public struct NatsMessage {
    
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

extension NatsMessage {
    public static func publish(payload: String, subject: String) -> String {
        guard let data = payload.data(using: String.Encoding.utf8) else { return "" }
        return "\(NatsOperation.publish.rawValue) \(subject) \(data.count)\r\n\(payload)\r\n"
    }
    public static func subscribe(subject: String, sid: String) -> String {
        return "\(NatsOperation.subscribe.rawValue) \(subject) \(sid)\r\n"
    }
    public static func unsubscribe(sid: String) -> String {
        return "\(NatsOperation.unsubscribe.rawValue) \(sid)\r\n"
    }
    public static func pong() -> String {
        return "PONG\r\n"
    }
    public static func connect(config: [String:Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: config, options: []) else { return "" }
        guard let payload = data.toString() else { return "" }
        return "\(NatsOperation.connect.rawValue) \(payload)\r\n"
    }
}
