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
                self.fire(.disconnected)
                break
            case [.endEncountered]:
                self.fire(.disconnected)
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
        if message.hasPrefix(NatsOperation.ping.rawValue) {
            self.sendMessage("PONG")
        } else if message.hasPrefix(NatsOperation.ok.rawValue) {
            // TODO: Log OK
        } else if message.hasPrefix(NatsOperation.error.rawValue) {
            // TODO: Log Error
        } else if message.hasPrefix(NatsOperation.message.rawValue) {
            self.handleIncomingMessage(message)
        }
    }
    
}
