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
    let autoRetry: Bool
    let autoRetryMax: Int
    
    init(
        verbose: Bool = false,
        pedantic: Bool = false,
        name: String = "SwiftyNats",
        autoRetry: Bool = false,
        autoRetryMax: Int = 3
    ) {
        self.verbose = verbose
        self.pedantic = pedantic
        self.name = name
        self.autoRetry = autoRetry
        self.autoRetryMax = autoRetryMax
    }
}
