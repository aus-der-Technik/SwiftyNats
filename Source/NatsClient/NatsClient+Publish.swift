//
//  NatsClient+Publish.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsPublish {
    
    open func publish(payload: String, toSubject subject: String) {
        sendMessage(NatsMessage.publish(payload: payload, subject: subject))
    }
    
    open func publish(payload: String, toSubject subject: NatsSubject) {
        publish(payload: payload, toSubject: subject.subject)
    }
    
}
