//
//  NatsServer.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

struct NatsServer {
    
    let serverId: String
    let version: String
    let go: String
    let host: String
    let port: UInt
    let authRequired: Bool
    let sslRequired: Bool
    let maxPayload: UInt
    
    init(_ data: [String: AnyObject]) {
        self.serverId = data["server_id"] as! String
        self.version = data["version"] as! String
        self.go = data["go"] as! String
        self.host = data["host"] as! String
        self.port = data["port"] as! UInt
        self.authRequired = data["auth_required"] as! Bool
        self.sslRequired = data["ssl_required"] as! Bool
        self.maxPayload = data["max_payload"] as! UInt
    }
    
}
