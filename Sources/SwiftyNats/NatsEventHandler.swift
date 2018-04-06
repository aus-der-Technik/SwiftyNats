//
//  NatsEventHandler.swift
//  SwiftyNats
//
//  Created by Ray Krow on 3/11/18.
//


internal struct NatsEventHandler {
    let listenerId: String
    let handler: (NatsEvent) -> Void
    let autoOff: Bool
    init(lid: String, handler: @escaping (NatsEvent) -> Void, autoOff: Bool = false) {
        self.listenerId = lid
        self.handler = handler
        self.autoOff = autoOff
    }
}
