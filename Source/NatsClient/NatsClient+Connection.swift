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
        
        // We could hit any number of errors while trying to connect to any
        // number of servers...here well just keep the last encountered one
        // so we have something helpful to throw up
        var connectionError: NatsError? = nil
        
        // If we have a list of `connectUrls` in our current server
        // add them to the list of knownServers here so we can attempt
        // to connect to them as well
        var knownServers = self.urls
        if let otherServers = self.server?.connectUrls {
            otherServers.forEach { knownServers.append(URL(string: $0)!) }
        }
        
        for server in knownServers {
            do {
                try self.openStream(to: server)
            } catch let error as NatsError {
                connectionError = error
                continue // to try next server
            }
            self.connectedUrl = server
        }
        
        guard let _ = self.connectedUrl else {
            self.disconnect()
            throw connectionError!
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
    
    // MARK - Internal Methods
    
    internal func retryConnection() {
        
        if self.config.autoRetry {
            while self.autoRetryCount < self.config.autoRetryMax {
                if let _ = try? self.connect() {
                    self.autoRetryCount = 0
                    return
                }
                self.autoRetryCount += 1
            }
        }
        
        self.fire(.disconnected)
    }
    
    // MARK - Private Methods
    
    fileprivate func openStream(to server: URL) throws {
        
        guard let host = server.host, let port = server.port else { throw NatsConnectionError("Invalid url provided (\(server.absoluteString))") }
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, host as CFString!, UInt32(port), &readStream, &writeStream) // -> send
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        guard let inStream = inputStream, let outStream = outputStream else { return }
        
        inStream.open()
        outStream.open()

        guard let info = inStream.readStreamWhenReady() else {
            throw NatsConnectionError("Did not get a response from the server")
        }
        
        guard info.hasPrefix(NatsOperation.info.rawValue) else {
            throw NatsConnectionError("Server responded with unexptected result")
        }
        
        guard let config = info.removeNewlines().removePrefix(NatsOperation.info.rawValue).toJsonDicitonary() else {
            throw NatsConnectionError("Failed to read server response")
        }
        
        self.server = NatsServer(config)
        
        guard let _ = self.server else {
            throw NatsConnectionError("Failed to connect to server")
        }
        
        if self.server!.authRequired {
            try self.authenticateWithServer(usingInStream: inStream, andOutStream: outStream)
        }
        
    }
    
    fileprivate func authenticateWithServer(usingInStream inStream: InputStream, andOutStream outStream: OutputStream) throws {
        
        guard let user = self.connectedUrl?.user, let password = self.connectedUrl?.password else {
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
