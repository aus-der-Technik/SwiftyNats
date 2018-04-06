//
//  NatsClientTests.swift
//  SwiftyNatsTests
//
//  Created by Ray Krow on 2/27/18.
//

import XCTest
@testable import SwiftyNats

class ConnectionTests: XCTestCase {

    static var allTests = [
        ("testClientConnection", testClientConnection),
        ("testClientServerSetWhenConnected", testClientServerSetWhenConnected),
        ("testClientBadConnection", testClientBadConnection)
    ]

    func testClientConnection() {

        let client = NatsClient(TestSettings.natsUrl)

        try? client.connect()
        XCTAssertTrue(client.state == .connected, "Client did not connect")

    }

    func testClientServerSetWhenConnected() {

        let client = NatsClient(TestSettings.natsUrl)

        try? client.connect()
        guard let _ = client.server else { XCTFail("Client did not connect to server correctly"); return }

    }

    func testClientBadConnection() {

        let client = NatsClient("notnats.net")

        try? client.connect()
        XCTAssertTrue(client.state == .disconnected, "Client should not have connected")

    }

}
