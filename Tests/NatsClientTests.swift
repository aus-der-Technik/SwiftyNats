import XCTest
@testable import SwiftyNats

class NatsSwiftyTests: XCTestCase {
    
    var natsClient: NatsClient!
    
    override func setUp() {
        
        self.natsClient = NatsClient("http://localhost:4222")
        
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testClientConnected() {
        try? natsClient.connect()
        
        XCTAssertTrue(natsClient.state == .connected, "Client is connected")
    }
    
    func testClientDisconnected() {
        natsClient.disconnect()
        
        XCTAssertTrue(natsClient.state == .disconnected, "Client is disconnected")
    }
    
}
