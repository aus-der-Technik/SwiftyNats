//
//  NatsClient+Connection.swift
//  SwiftyNatsPackageDescription
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation


extension NatsClient: NatsConnection {
    
    // MARK - Implement NatsConnection Protocol
    
    public func connect() throws {
        
        try self.openStream()
        
        self.state = .connected
        self.fire(NatsEventType.connected)
        
        guard let readStream = inputStream, let writeStream = outputStream else { return }
        
        for stream in [readStream, writeStream] {
            stream.delegate = self
            stream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture as Date)
    }
    
    public func disconnect() {
        self.state = .disconnected
    }
    
    // MARK - Private Methods
    
    private func openStream() throws {
        
        guard self.state == .connected else { return }
        guard let host = self.url.host, let port = self.url.port else { return }
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, host as CFString!, UInt32(port), &readStream, &writeStream) // -> send
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        guard let inStream = inputStream, let outStream = outputStream else { return }
        
        inStream.open()
        outStream.open()

        guard let info = inStream.readStreamWhenReady() else { throw "Error: Problem connecting to server. No response" }
        guard info.hasPrefix(NatsProtocol.info.rawValue) else { throw "Error: Server responded with unexptected result" }
        guard let config = info.flattenedMessage().removePrefix(NatsProtocol.info.rawValue).convertToDictionary() else { throw "Error: Failed to read server response" }
        
        self.server = NatsServer(config)
        
        guard let _ = self.server else { throw "Error: Failed to connect to server" }
        
        if !self.server!.authRequired{
            return
        }
        
        try self.authenticateWithServer(usingInStream: inStream, andOutStream: outStream)
        
    }
    
    private func authenticateWithServer(usingInStream inStream: InputStream, andOutStream outStream: OutputStream) throws {
        
        guard let user = self.url.user, let password = self.url.password else {
            throw "Error: Server authentication requires url with basic authentication"
        }
        
        let config = [
            "verbose": self.config.verbose,
            "pedantic": self.config.pedantic,
            "ssl_required": server!.sslRequired,
            "name": self.config.name,
            "lang": self.config.lang,
            "version": self.config.version,
            "user": user,
            "pass": password
            ] as [String : Any]
        
        let configData = try JSONSerialization.data(withJSONObject: config, options: [])
        
        if let configString = configData.toString() {
            if let data = "\(NatsProtocol.connect.rawValue) \(configString)\r\n".data(using: String.Encoding.utf8) {
                
                outStream.writeStreamWhenReady(data) // -> send
                
                if let info = inStream.readStreamWhenReady() { // <- receive
                    
                    if !info.hasPrefix(NatsProtocol.error.rawValue) {
                        return
                    }
                    
                }
            }
        }
        
        throw "Error: Failed to authenticate with nats server"
        
    }
    
}
