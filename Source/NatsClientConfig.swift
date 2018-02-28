//
//  NatsClientConfig.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//



struct NatsClientConfig {
    let verbose: Bool
    let pedantic: Bool
    let name: String
    let lang: String
    let version: String
    init(
        verbose: Bool = false,
        pedantic: Bool = false,
        name: String = "SwiftyNats",
        lang: String = "Swift",
        version: String = "1.0.0-alpha"
    ) {
       self.verbose = verbose
        self.pedantic = pedantic
        self.name = name
        self.lang = lang
        self.version = version
    }
}
