//
//  NatsClientTests.swift
//  SwiftyNatsTests
//
//  Created by Ray Krow on 2/27/18.
//

import XCTest
@testable import SwiftyNats

class NatsClientTests: XCTestCase {
    
    let natsUrl: String = "http://nats.oakudo.com:4222"
    
    func testClientConnection() {
        
        let client = NatsClient(natsUrl)

        try? client.connect()
        XCTAssertTrue(client.state == .connected, "Client did not connect")
        
        client.disconnect()
        XCTAssertTrue(client.state == .disconnected, "Client did not disconnect")
        
    }
    
    func testClientPublish() {
        
        let client = NatsClient(natsUrl)
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        
        let _ = client.subscribe(to: "swift.test") { m in
            print("Recieved")
            print(m.payload!)
        }
        
        client.publish("a test message", to: "swift.test")
        client.publish("a second message", to: "swift.test")
        client.publish("the final message", to: "swift.test")

        sleep(1)
        
        let _ = client.subscribe(to: "swift.test.*") { m in
            print("Recieved")
            print(m.payload!)
        }
        
        for _ in 0...10 {
            client.publish("a test message", to: "swift.test.a")
        }
        
        sleep(4)
        
        client.disconnect()
        
    }
    
    func testClientConnectedEvent() {
        
        let client = NatsClient(natsUrl)
        
        var hasConnected = false
        client.on(.connected) { _ in
            hasConnected = true
        }
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        
        XCTAssertTrue(hasConnected, "Subscriber was not notified of connection")
        
        client.disconnect()
        
    }
    
    func testClientDisconnectedEvent() {
        
        let client = NatsClient(natsUrl)
        
        var state = "a"
        client.on(.disconnected) { _ in
            state += "b"
        }
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        client.disconnect()
        
        XCTAssertTrue(state == "ab", "Subscriber was not notified of disconnection")
        
    }
    
    func testClientEventOff() {
        
        let client = NatsClient(natsUrl)
        
        var state = "a"
        let eid = client.on(.disconnected) { _ in
            state += "b"
        }
        
        client.off(eid)
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        client.disconnect()
        
        XCTAssertTrue(state == "a", "Subscriber was notified of connection and should not have been")
        
    }
    
    func testClientEventMultiple() {
        
        let client = NatsClient(natsUrl)
        
        var counter = 0
        client.on([.connected, .disconnected]) { _ in
            counter += 1
        }
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        client.disconnect()
        
        XCTAssertTrue(counter == 2, "Subscriber was not notified of correct events")
    }
    
    func testClientEventAutoOff() {
        
        let client = NatsClient(natsUrl)
        
        var counter = 0
        client.on([.connected, .disconnected], autoOff: true) { _ in
            counter += 1
        }
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        client.disconnect()
        
        XCTAssertTrue(counter == 1, "Subscriber was notified of incorrect events after autoOff")
    }
    
    func testClientSubscription() {
        
        let client = NatsClient(natsUrl)
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        
        let handler: (NatsMessage) -> Void = { message in
            
        }
        
        guard let _ = try? client.subscribeSync(to: "swift.test", handler) else {
            XCTFail("Subscription failed");
            return
        }
        
        client.disconnect()
        
    }
    
    func testClientSubscriptionInQueue() {
        
        let client = NatsClient(natsUrl)
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        
        let handler: (NatsMessage) -> Void = { message in
            
        }
        
        guard let _ = try? client.subscribeSync(to: "swift.test", asPartOf: "swift_test_queue", handler) else {
            XCTFail("Subscription failed");
            return
        }
        
        client.disconnect()
        
    }
    
    func testClientFlushQueue() {
        
        let client = NatsClient(natsUrl)
        
        guard let _ = try? client.connect() else { XCTFail("Connection failed"); return }
        
        guard let _ = try? client.flushQueue(maxWait: TimeInterval(2)) else {
            XCTFail("Failed to flush queue");
            return
        }
        
        client.disconnect()
        
    }
    
}
