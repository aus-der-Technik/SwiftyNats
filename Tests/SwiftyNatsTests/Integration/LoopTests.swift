//
//  LoopTests.swift
//  SwiftyNatsTests
//

import XCTest
@testable import SwiftyNats

class LoopTests: XCTestCase {
    
    func testReadSubscriptionInLoop() {
        
        let clientPublish = NatsClient(TestSettings.natsUrl)
        let clientSubscribe = NatsClient(TestSettings.natsUrl)
        
        try? clientPublish.connect()
        try? clientSubscribe.connect()
        
        let runCountExpectation = expectation(description: "Callback Subscribe")
        runCountExpectation.expectedFulfillmentCount = 100
        clientSubscribe.subscribe(to: "swift.test") { message in
            guard let byteCount = message.byteCount else {
                XCTFail("No message.byteCount")
                return
            }
            guard let payload = message.payload else {
                XCTFail("No message.payload")
                return
            }
            if byteCount != payload.count {
                print("byteCount \(byteCount)")
                print("payload [\(payload.count)] \(payload)")
                XCTFail("ERROR DETECTED")
            }
            runCountExpectation.fulfill()
        }
        
        for i in 1...100 {
            clientPublish.publish("S....................\(i)....................E", to: "swift.test")
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
        
        clientPublish.disconnect()
        clientSubscribe.disconnect()
    }
    
}
