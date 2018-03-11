//
//  NatsClientConfig.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//



public struct NatsClientConfig {
    
    // Required for nats server
    let verbose: Bool
    let pedantic: Bool
    let name: String
    let lang: String = "Swift"
    let version: String = "1.0.0-alpha"
    
    // Internal config vars
    var autoRetry: Bool = false
    var autoRetryMax: Int = 3
    var internalQueueMax: Int = 100
    
    init(
        verbose: Bool = false,
        pedantic: Bool = false,
        name: String = "SwiftyNats"
    ) {
        self.verbose = verbose
        self.pedantic = pedantic
        self.name = name
    }
}
