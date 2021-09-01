//
//  NatsClientConfig.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//  updated by aus der Technik, 2021
//

import Foundation
import Logging

var logger = Logger(label: "nats-client")
var libVersion = "2.0"

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
        name: String = "SwiftyNats \(libVersion)",
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
