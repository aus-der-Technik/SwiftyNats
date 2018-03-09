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
    case response = "response"
    case error = "error"
}

internal enum NatsOperation: String {
    case connect = "CONNECT"
    case subscribe = "SUB"
    case unsubscribe = "UNSUB"
    case publish = "PUB"
    case message = "MSG"
    case info = "INFO"
    case ok = "+OK"
    case error = "-ERR"
    case ping = "PING"
    case pong = "PONG"
}

open class NatsClient: NSObject {
    
    let urls: [URL]
    var connectedUrl: URL?
    let config: NatsClientConfig
    
    internal var inputStream: InputStream?
    internal var outputStream: OutputStream?
    internal var server: NatsServer?
    internal var writeQueue = OperationQueue()
    internal var eventHandlerStore: [ NatsEvent: Array<(NatsEvent) -> Void> ] = [:]
    internal var subjectHandlerStore: [ NatsSubject: (NatsMessage) -> Void] = [:]
    internal var autoRetryCount: Int = 0
    internal var messageQueue: [NatsMessage] = []
    internal var state: NatsState = .disconnected
    
    public init(_ urls: [String], _ config: NatsClientConfig) {

        var servers: [URL] = []
        for url in urls {
            servers.append(URL(string: url)!)
        }
        
        self.urls = servers
        self.config = config
        
        writeQueue.maxConcurrentOperationCount = 1
    }
    
    convenience init(_ url: String, _ config: NatsClientConfig? = nil) {
        let urls = [ url ]
        let config = config ?? NatsClientConfig()
        self.init(urls, config)
    }
    
}

protocol NatsConnection {
    func connect() throws
    func disconnect()
}

protocol NatsSubscribe {
    func subscribe(to subject: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject
    func subscribe(to subject: String, asPartOf queue: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject
    func unsubscribe(from subject: NatsSubject)
    
    func subscribeSync(to subject: String, _ handler: @escaping (NatsMessage) -> Void) throws -> NatsSubject
    func subscribeSync(to subject: String, asPartOf queue: String, _ handler: @escaping (NatsMessage) -> Void) throws -> NatsSubject
    func unsubscribeSync(from subject: NatsSubject) throws
}

protocol NatsPublish {
    func publish(_ payload: String, to subject: String)
    func publish(_ payload: String, to subject: NatsSubject)
    func reply(toMessage message: NatsMessage, withPayload payload: String)
    
    func publishSync(_ payload: String, to subject: String) throws
    func publishSync(_ payload: String, to subject: NatsSubject) throws
    func replySync(toMessage message: NatsMessage, withPayload payload: String) throws
}

protocol NatsEventBus {
    func on(_ event: [NatsEvent], _ handler: @escaping (NatsEvent) -> Void)
    func on(_ envet: NatsEvent, _ handler: @escaping (NatsEvent) -> Void)
}

protocol NatsQueue {
    var queueCount: Int { get }
    func flushQueue(maxWait: TimeInterval?) throws
    func flushQueue()
}

