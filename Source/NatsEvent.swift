//
//  NatsEvent.swift
//  SwiftyNatsPackageDescription
//
//  Created by Ray Krow on 2/27/18.
//


enum NatsEventType: String {
    case connected = "connected"
    case disconnected = "disconnected"
    case message = "message"
    case ping = "ping"
}

struct NatsEvent {
    let type: NatsEventType
    let message: String?
    init(type: NatsEventType, message: String? = nil) {
        self.type = type
        self.message = message
    }
}
