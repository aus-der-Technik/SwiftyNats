//
//  NatsClient+Connection.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsConnection {
    
    // MARK - Implement NatsConnection Protocol
    
    open func connect() throws {
        
        guard self.state != .connected else { return }
        
        do {
            try self.openStream()
        } catch let error as NatsError {
            self.disconnect()
            throw error
        }
        
        self.state = .connected
        self.fire(.connected)
        
        guard let readStream = inputStream, let writeStream = outputStream else { return }
        
        for stream in [readStream, writeStream] {
            stream.delegate = self
            stream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture as Date)
    }
    
    open func disconnect() {
        
        guard let newReadStream = self.inputStream, let newWriteStream = self.outputStream else { return }
        
        for stream in [newReadStream, newWriteStream] {
            stream.delegate = nil
            stream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            stream.close()
        }
        
        self.state = .disconnected
        self.fire(.disconnected)
        
    }
    
    // MARK - Private Methods
    
    fileprivate func openStream() throws {
        
        guard let host = self.url.host, let port = self.url.port else { throw NatsConnectionError("Invalid url provided (\(self.url.absoluteString))") }
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, host as CFString!, UInt32(port), &readStream, &writeStream) // -> send
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        guard let inStream = inputStream, let outStream = outputStream else { return }
        
        inStream.open()
        outStream.open()

        guard let info = inStream.readStreamWhenReady() else { throw NatsConnectionError("Did not get a response from the server") }
        guard info.hasPrefix(NatsOperation.info.rawValue) else { throw NatsConnectionError("Server responded with unexptected result") }
        guard let config = info.removeNewlines().removePrefix(NatsOperation.info.rawValue).toJsonDicitonary() else { throw NatsConnectionError("Failed to read server response") }
        
        self.server = NatsServer(config)
        
        guard let _ = self.server else { throw NatsConnectionError("Failed to connect to server") }
        
        if !self.server!.authRequired{
            return
        }
        
        try self.authenticateWithServer(usingInStream: inStream, andOutStream: outStream)
        
    }
    
    fileprivate func authenticateWithServer(usingInStream inStream: InputStream, andOutStream outStream: OutputStream) throws {
        
        guard let user = self.url.user, let password = self.url.password else {
            throw NatsConnectionError("Server authentication requires url with basic authentication")
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
        
        if let data = NatsMessage.connect(config: config).data(using: String.Encoding.utf8) {
            
            outStream.writeStreamWhenReady(data) // -> send
            
            if let info = inStream.readStreamWhenReady() { // <- receive
                
                if !info.hasPrefix(NatsOperation.error.rawValue) {
                    return
                }
                
            }
        }
        
        throw NatsConnectionError("Failed to authenticate with nats server")
        
    }
    
}
