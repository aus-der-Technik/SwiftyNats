//
//  NatsClient+Connection.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation
import NIO

extension NatsClient: NatsConnection {
    
    // MARK - Implement NatsConnection Protocol
    
    open func connect() throws {
        
        guard self.state != .connected else { return }
        
        let group = DispatchGroup()
        group.enter()
        
        let thread = Thread(target: self, selector: #selector(self.setupConnection), object: group)
        thread.start()
        
        group.wait()

        if let error = self.connectionError {
            throw error
        }

        if self.server?.authRequired == true {
            try self.authenticateWithServer()
        }
        
        self.state = .connected
        self.fire(.connected)
        
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
        
        self.fire(.reconnecting)
        var retryCount = 0
        
        if self.config.autoRetry {
            while retryCount < self.config.autoRetryMax {
                if let _ = try? self.connect() {
                    return
                }
                retryCount += 1
                usleep(UInt32(self.config.connectionRetryDelay))
            }
        }
        
        self.disconnect()
    }
    
    // MARK - Private Methods
    
    @objc
    fileprivate func setupConnection(_ group: DispatchGroup) throws {
        
        self.connectionError = nil
        
        // If we have a list of `connectUrls` in our current server
        // add them to the list of knownServers here so we can attempt
        // to connect to them as well
        var knownServers = self.urls
        if let otherServers = self.server?.connectUrls {
            knownServers.append(contentsOf: otherServers)
        }
        
        for server in knownServers {
            do {
                try self.openStream(to: server)
            } catch let e as NatsError {
                self.connectionError = e
                continue // to try next server
            }
            self.connectedUrl = URL(string: server)
        }
        
        if let _ = self.connectionError {
            group.leave()
        }
        
        guard let readStream = self.inputStream, let writeStream = self.outputStream else { return }
        
        for stream in [readStream, writeStream] {
            stream.delegate = self
            stream.schedule(in: .current, forMode: .defaultRunLoopMode)
        }
        
        group.leave()
        
        RunLoop.current.run()
        
    }
    
    fileprivate func openStream(to url: String) throws {
        
        guard let server = URL(string: url) else {
            throw NatsConnectionError("Invalid url provided: (\(url))")
        }
        
        guard let host = server.host, let port = server.port else {
            throw NatsConnectionError("Invalid url provided: (\(server.absoluteString))")
        }
                
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, host as CFString!, UInt32(port), &readStream, &writeStream) // -> send
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream?.open()
        self.outputStream?.open()

        guard let info = self.inputStream?.readStreamWhenReady() else {
            throw NatsConnectionError("Did not get a response from the server")
        }
        
        guard info.hasPrefix(NatsOperation.info.rawValue) else {
            throw NatsConnectionError("Server responded with unexptected result")
        }
        
        guard let config = info.removeNewlines().removePrefix(NatsOperation.info.rawValue).toJsonDicitonary() else {
            throw NatsConnectionError("Failed to read server response")
        }
        
        self.server = NatsServer(config)
        
    }
    
    fileprivate func authenticateWithServer() throws {
        
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
            
            self.outputStream?.writeStreamWhenReady(data) // -> send
            
            if let info = self.inputStream?.readStreamWhenReady() { // <- receive
                
                if !info.hasPrefix(NatsOperation.error.rawValue) {
                    return
                }
                
            }
        }
        
        throw NatsConnectionError("Failed to authenticate with nats server")
        
    }
    
}
