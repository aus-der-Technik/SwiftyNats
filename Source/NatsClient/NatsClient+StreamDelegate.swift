//
//  NatsClient+StreamDelegate.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: StreamDelegate {
    
    // MARK - Implement StreamDelegate
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch aStream {
        case inputStream!:

            switch eventCode {
            case [.hasBytesAvailable]:
                if let data = inputStream?.readStream() {
                    self.handleIncomingMessageData(data)
                }
                break
            case [.errorOccurred, .endEncountered]:
                self.disconnect()
                self.retryConnection()
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
    
    // MARK - Implement Internal Methods
    
    internal func sendMessage(_ message: String) {
        if let data = message.data(using: String.Encoding.utf8) {
            sendMessage(data)
        }
    }
    
    internal func getResponseFromStream() -> NatsResponse {
        guard let response = self.inputStream?.readStreamWhenReady() else {
            return NatsResponse.error()
        }
        return NatsResponse(response)
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
        
    fileprivate func handleIncomingMessageData(_ data: Data) {
        
        guard let content = data.toString() else { return }
        
        let messages: [String] = content.parseOutMessages()
        
        for message in messages {
            
            guard let type = message.getMessageType() else { return }
            
            switch type {
            case .ping:
                self.sendMessage(NatsMessage.pong())
                continue
            case .ok:
                self.fire(.response)
                continue
            case .error:
                self.fire(.error)
                continue
            case .message:
                self.handleIncomingMessage(message)
                continue
            default:
                continue
            }

        }

    }
    
    fileprivate func handleIncomingMessage(_ messageStr: String) {
        
        if self.queueCount > self.config.internalQueueMax {
            self.fire(.dropped)
            return
        }
        
        guard let message = parseMessage(messageStr) else { return }
        
        guard let handler = self.subjectHandlerStore[message.subject] else { return }
        
        self.messageQueue.addOperation {
            handler(message)
        }

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
