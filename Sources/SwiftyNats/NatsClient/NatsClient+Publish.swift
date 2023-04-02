//
//  NatsClient+Publish.swift
//  SwiftyNats
//

import Foundation
import Dispatch

extension NatsClient: NatsPublish {

    // MARK: - Implement NatsPublish Protocol

    public func publish(_ payload: String, to subject: String) {
        logger.info("publish \(payload.count) characters to subject \(subject)")
        sendMessage(NatsMessage.publish(payload: payload, subject: subject))
    }

    public func publish(_ payload: String, to subject: NatsSubject) {
        publish(payload, to: subject.subject)
    }

    public func reply(to message: NatsMessage, withPayload payload: String) {
        guard let replySubject = message.replySubject else { return }
        logger.info("reply \(payload.count) characters to subject \(replySubject.subject)")
        publish(payload, to: replySubject.subject)
    }

    public func publishSync(_ payload: String, to subject: String) throws {

        let group = DispatchGroup()
        group.enter()

        var response: NatsEvent?

        self.on([.response, .error], autoOff: true) { e in
            response = e
            group.leave()
        }

        publish(payload, to: subject)

        group.wait()

        if response == .error {
            throw NatsPublishError("Error response from server")
        }

    }

    public func publishSync(_ payload: String, to subject: NatsSubject) throws {
        try publishSync(payload, to: subject.subject)
    }

    public func replySync(to message: NatsMessage, withPayload payload: String) throws {
        guard let replySubject = message.replySubject else { return }
        try publishSync(payload, to: replySubject.subject)
    }

}
