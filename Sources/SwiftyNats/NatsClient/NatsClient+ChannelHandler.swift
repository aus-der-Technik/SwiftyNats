//
//  NatsClient+ChannelInboundHandler.swift
//  SwiftyNats
//
//  Created by Ray Krow on 4/4/18.
//

import Foundation
import NIO

extension NatsClient: ChannelInboundHandler {

    public typealias InboundIn = ByteBuffer

    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {

        var buffer = self.unwrapInboundIn(data)
        guard let messages = buffer.readString(length: buffer.readableBytes)?.parseOutMessages() else { return }

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
            case .info:
                self.updateServerInfo(with: message)
                continue
            default:
                continue
            }

        }
    }

    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        self.disconnect()
        ctx.close(promise: nil)
        self.fire(.disconnected)
    }
}


extension NatsClient {

    // MARK - Implement Internal Methods

    internal func sendMessage(_ message: String) {

        guard self.state == .connected else { return }

        var buffer = self.channel?.allocator.buffer(capacity: message.utf8.count)
        buffer?.write(string: message)
        let _ = self.channel?.writeAndFlush(buffer)

    }

    // MARK - Implement Private Methods

    fileprivate func updateServerInfo(with info: String) -> Void {
        // TODO: CP - Possibly quit here if reading the config failed.
        // Then disconnect. Not 100% sure when this would happen
        if let config = info.removeNewlines().removePrefix(NatsOperation.info.rawValue).toJsonDicitonary() {
            self.server = NatsServer(config)
            self.fire(.informed)
        }
    }

    fileprivate func handleIncomingMessage(_ messageStr: String) {

        if self.queueCount > self.config.internalQueueMax {
            self.fire(.dropped)
            return
        }

        guard let message = NatsMessage.parse(messageStr) else { return }

        guard let handler = self.subjectHandlerStore[message.subject] else { return }

        self.messageQueue.addOperation {
            handler(message)
        }

    }

}
