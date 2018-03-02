//
//  NatsClientTests.swift
//  SwiftyNatsTests
//
//  Created by Ray Krow on 2/27/18.
//

import XCTest
@testable import SwiftyNats

class NatsSwiftyTests: XCTestCase {
    
    var natsServer: Process?
    let natsUrl = "http://localhost:4222"
    
    override func setUp() {
        
        natsServer = Process()
        natsServer?.launchPath = "/usr/local/bin/docker"
        natsServer?.arguments = [ "run", "-p", "4222:4222", "nats:1.0.4" ]
        natsServer?.launch()
        
        sleep(2) // Give time for docker to spin up nats
        
        super.setUp()
    }
    
    override func tearDown() {
        
        natsServer?.terminate()
        
        super.tearDown()
    }
    
    
    func testClientConnection() {
        
        let natsClient = NatsClient(natsUrl)

        try? natsClient.connect()
        XCTAssertTrue(natsClient.state == .connected, "Client did not connect")
        
        natsClient.disconnect()
        XCTAssertTrue(natsClient.state == .disconnected, "Client did not disconnect")
        
    }
    
    func testClientPublish() {
        
        let natsClient = NatsClient(natsUrl)
        
        guard let _ = try? natsClient.connect() else { XCTAssertTrue(false, "Client did not connect"); return }
        
        natsClient.publish(payload: "a test message", toSubject: "swift.test")
        
        sleep(2) // Publish happens async, keep the process alive long enough for the message to go out
        
        natsClient.disconnect()
        
    }
    
    func testClientEvents() {
        
        let natsClient = NatsClient(natsUrl)
        
        var hasConnected = false
        natsClient.on(NatsEventType.connected) { event in
            hasConnected = true
        }
        
        guard let _ = try? natsClient.connect() else { XCTAssertTrue(false, "Client did not connect"); return }
        
        XCTAssertTrue(hasConnected, "Subscriber was not notified of connection")
        
    }
    
    // Requires that you manually publish a message during test wait period
    func testClientSubscription() {
        
        let natsClient = NatsClient(natsUrl)
        guard let _ = try? natsClient.connect() else { XCTAssertTrue(false, "Client did not connect"); return }
        
        var didRecieveMessage = false
        let _ = natsClient.subscribe(toSubject: "swift.test") { message in
            didRecieveMessage = true
        }
        
        sleep(1)
        
        XCTAssertTrue(didRecieveMessage, "Client did not recieve message")
        
    }
    
    
}
