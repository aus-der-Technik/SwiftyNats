//
//  NatsClient.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

enum NatsState {
    case connected
    case disconnected
}

public enum NatsEvent: String {
    case connected = "connected"
    case disconnected = "disconnected"
}

open class NatsClient: NSObject {
    
    // FIX: Want all these to be private but then extensions in other files can't see them
    
    let url: URL
    let config: NatsClientConfig
    
    var state: NatsState = .disconnected
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var server: NatsServer?
    var writeQueue = OperationQueue()
    var eventHandlerStore: [ NatsEvent: Array<() -> Void> ] = [:]
    var subjectHandlerStore: [ NatsSubject: (NatsMessage) -> Void] = [:]
    var autoRetryCount: Int = 0
    
    public init(_ url: String, _ config: NatsClientConfig? = nil) {
        self.url = URL(string: url)!
        self.config = config ?? NatsClientConfig()
        
        writeQueue.maxConcurrentOperationCount = 1
    }
    
}

protocol NatsConnection {
    func connect() throws
    func disconnect()
}

protocol NatsSubscribe {
    func subscribe(to subject: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject
    func unsubscribe(from subject: NatsSubject)
}

protocol NatsPublish {
    func publish(_ payload: String, to subject: String)
    func publish(_ payload: String, to subject: NatsSubject)
    func reply(toMessage message: NatsMessage, withPayload payload: String)
}

protocol NatsEvents {
    func on(_ event: NatsEvent, _ handler: @escaping () -> Void)
}

