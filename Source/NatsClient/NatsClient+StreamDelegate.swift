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
                    self.handleIncomingMessageStream(data)
                }
                break
            case [.errorOccurred]:
                self.fire(NatsEventType.disconnected)
                break
            case [.endEncountered]:
                self.fire(NatsEventType.disconnected)
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK - Implement Private Methods
    
    private func handleIncomingMessageStream(_ data: Data) {
        guard let message = data.toString() else { return }
        if message.hasPrefix(NatsProtocol.ping.rawValue) {
            // TODO: Respond with PONG
        } else if message.hasPrefix(NatsProtocol.ok.rawValue) {
            // TODO: Log OK
        } else if message.hasPrefix(NatsProtocol.error.rawValue) {
            // TODO: Log Error
        } else if message.hasPrefix(NatsProtocol.message.rawValue) {
            self.handleIncomingMessage(message)
        }
    }
    
}
