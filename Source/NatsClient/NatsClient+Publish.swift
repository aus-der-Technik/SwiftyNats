//
//  NatsClient+Publish.swift
//  SwiftyNatsPackageDescription
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsPublish {
    
    public func publish(payload: String, toSubject subject: String) {
        
        if let data = payload.data(using: String.Encoding.utf8) {
            sendMessage("\(NatsProtocol.publish.rawValue) \(subject) \(data.count)\r\n\(payload)\r\n")
        }
        
    }
    
    func sendMessage(_ message: String) {
        if let data = message.data(using: String.Encoding.utf8) {
            sendMessage(data)
        }
    }
    
    func sendMessage(_ data: Data) {
        guard self.state == .connected else { return }
        
        self.writeQueue.addOperation { [weak self] in
            guard let s = self else { return }
            guard let stream = s.outputStream else { return }
            
            stream.writeStreamWhenReady(data)
        }
    }
    
}
