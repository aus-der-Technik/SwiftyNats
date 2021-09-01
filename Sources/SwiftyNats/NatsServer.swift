//
//  NatsServer.swift
//  SwiftyNats
//
//  updated by aus der Technik, 2021
//

import Foundation

struct NatsServer {
    
    let host: String
    let port: UInt
    let clientIp: String?
    let clientId: UInt?
    let serverName: String
    let serverId: String
    let maxPayload: UInt
    let version: String
    let go: String
    let proto: UInt
    let gitCommit: String?

    let authRequired: Bool?
    let sslRequired: Bool?

    let connectUrls: [String]?
    let tlsVerify: Bool?
    
    init(_ data: [String: AnyObject]) {
        self.host = data["host"] as! String
        self.port = data["port"] as! UInt
        self.clientIp = data["client_ip"] as? String
        self.clientId = data["client_id"] as? UInt
        self.serverName = data["server_name"] as! String
        self.serverId = data["server_id"] as! String
        self.maxPayload = data["max_payload"] as! UInt
        self.version = data["version"] as? String ?? "0.0.0"
        self.go = data["go"] as? String ?? ""
        self.proto = data["proto"] as! UInt
        self.gitCommit = data["git_commit"] as? String ?? ""
        
        self.authRequired = data["auth_required"] as? Bool ?? false
        self.sslRequired = data["ssl_required"] as? Bool ?? false
        
        self.connectUrls = data["connect_urls"] as? [String]
        self.tlsVerify = data["tls_verify"] as? Bool
    }
    
}
