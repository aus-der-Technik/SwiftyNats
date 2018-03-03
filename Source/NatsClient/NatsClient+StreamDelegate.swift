//
//  NatsClient+StreamDelegate.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: StreamDelegate {
    
    // MARK - Implement StreamDelegate
    
    open func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch aStream {
        case inputStream!:
            switch eventCode {
            case [.hasBytesAvailable]:
                if let data = inputStream?.readStream() {
                    self.handleIncomingMessage(data)
                }
                break
            case [.errorOccurred]:
                self.disconnect()
                self.fire(.disconnected)
                break
            case [.endEncountered]:
                self.disconnect()
                self.fire(.disconnected)
                break
            default:
                break
            }
        default:
            break
        }
    }

}

extension NatsClient {
    
    internal func sendMessage(_ message: String) {
        if let data = message.data(using: String.Encoding.utf8) {
            sendMessage(data)
        }
    }
    
    // MARK - Implement Private Methods
    
    fileprivate func sendMessage(_ data: Data) {
        
        guard self.state == .connected else { return }
        
        self.writeQueue.addOperation { [weak self] in
            
            guard let s = self else { return }
            guard let stream = s.outputStream else { return }
            
            stream.writeStreamWhenReady(data)
        }
    }
    
    fileprivate func handleIncomingMessage(_ data: Data) {
        guard let message = data.toString() else { return }
        if message.hasPrefix(NatsOperation.ping.rawValue) {
            self.sendMessage(NatsMessage.pong())
        } else if message.hasPrefix(NatsOperation.ok.rawValue) {
            // TODO: Log OK
        } else if message.hasPrefix(NatsOperation.error.rawValue) {
            // TODO: Log Error
        } else if message.hasPrefix(NatsOperation.message.rawValue) {
            self.handleIncomingMessage(message)
        }
    }
    
    fileprivate func handleIncomingMessage(_ messageStr: String) {
        
        guard let message = parseMessage(messageStr) else { return }
        
        guard let handler = self.subjectHandlerStore[message.subject] else { return }
        
        handler(message)
    }
    
    fileprivate func parseMessage(_ message: String) -> NatsMessage? {
        let components = message.components(separatedBy: CharacterSet.newlines).filter { !$0.isEmpty }
        
        if components.count <= 0 { return nil }
        
        let payload = components[1]
        let header = components[0]
            .removePrefix(NatsOperation.message.rawValue)
            .components(separatedBy: CharacterSet.whitespaces)
            .filter { !$0.isEmpty }
        
        let subject: String
        let sid: String
        let byteCount: UInt32?
        let replySubject: String?
        
        switch (header.count) {
        case 3:
            subject = header[0]
            sid = header[1]
            byteCount = UInt32(header[2])
            replySubject = nil
            break
        case 4:
            subject = header[0]
            sid = header[1]
            replySubject = nil
            byteCount = UInt32(header[3])
            break
        default:
            return nil
        }
        
        return NatsMessage(
            payload: payload,
            byteCount: byteCount,
            subject: NatsSubject(subject: subject, id: sid),
            replySubject: replySubject == nil ? nil : NatsSubject(subject: replySubject!)
        )
    }
    
}
