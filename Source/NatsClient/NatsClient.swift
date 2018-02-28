import Foundation

enum NatsState {
    case connected
    case disconnected
}

class NatsClient: NSObject {
    
    // FIX: Want all these to be private but then extensions in other files can't see them
    
    let url: URL
    let config: NatsClientConfig
    
    var state: NatsState = .disconnected
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var server: NatsServer?
    var writeQueue = OperationQueue()
    var eventHandlerStore: [ NatsEventType: Array<(NatsEvent) -> Void> ] = [:]
    var subjectHandlerStore: [ NatsSubject: (NatsMessage) -> Void] = [:]
    
    public init(_ url: String, _ config: NatsClientConfig = NatsClientConfig()) {
        self.url = URL(string: url)!
        self.config = config
        
        writeQueue.maxConcurrentOperationCount = 1
    }
    
}

protocol NatsConnection {
    func connect() throws
    func disconnect()
}

protocol NatsSubscription {
    func subscribe(toSubject subject: String, _ handler: @escaping (NatsMessage) -> Void) -> NatsSubject
    func unsubscribe(fromSubject subject: NatsSubject)
}

protocol NatsPublish {
    func publish(payload: String, toSubject subject: String)
    
    // Private
    func sendMessage(_ message: String)
    func sendMessage(_ message: Data)
}

protocol NatsEvents {
    func on(_ event: NatsEventType, _ handler: @escaping (NatsEvent) -> Void)
    
    // Private
    func fire(_ eventType: NatsEventType)
    func fire(_ eventType: NatsEventType, _ message: String?)
}

