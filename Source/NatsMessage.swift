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
    let mid: String
    
    init(payload: String?, byteCount: UInt32?, subject: NatsSubject, replySubject: NatsSubject? = nil) {
        self.payload = payload
        self.byteCount = byteCount
        self.subject = subject
        self.replySubject = replySubject
        self.mid = UUID().uuidString
    }
    
}

extension NatsMessage {
    public static func publish(payload: String, subject: String) -> String {
        guard let data = payload.data(using: String.Encoding.utf8) else { return "" }
        return "\(NatsOperation.publish.rawValue) \(subject) \(data.count)\r\n\(payload)\r\n"
    }
    public static func subscribe(subject: String, sid: String, queue: String = "") -> String {
        return "\(NatsOperation.subscribe.rawValue) \(subject) \(queue) \(sid)\r\n"
    }
    public static func unsubscribe(sid: String) -> String {
        return "\(NatsOperation.unsubscribe.rawValue) \(sid)\r\n"
    }
    public static func pong() -> String {
        return "\(NatsOperation.pong.rawValue)\r\n"
    }
    public static func ping() -> String {
        return "\(NatsOperation.ping.rawValue)\r\n"
    }
    public static func connect(config: [String:Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: config, options: []) else { return "" }
        guard let payload = data.toString() else { return "" }
        return "\(NatsOperation.connect.rawValue) \(payload)\r\n"
    }
}
