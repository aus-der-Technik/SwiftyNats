//
//  NatsClientConfig.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation
import Logging

var logger = Logger(label: "nats-client")

public struct NatsClientConfig {
    
    // logging
    var loglevel: Logger.Level = .error {
        didSet {
            logger.logLevel = loglevel
        }
    }
    
    // Required for nats server
    let verbose: Bool
    let pedantic: Bool
    let name: String
    let lang: String = "Swift"
    let version: String = "2.0.0"
    
    // Internal config vars
    var autoRetry: Bool = false
    var autoRetryMax: Int = 3
    var internalQueueMax: Int = 100
    var connectionRetryDelay: TimeInterval = 5
    
    init(
        verbose: Bool = false,
        pedantic: Bool = false,
        name: String = "SwiftyNats",
        loglevel: Logger.Level? = .error
    ) {
        self.verbose = verbose
        self.pedantic = pedantic
        self.name = name

        if let level = loglevel {
            self.loglevel = level
        }
    }
}
