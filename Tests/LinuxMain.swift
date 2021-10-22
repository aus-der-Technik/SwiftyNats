//
//  LinuxMain.swift
//  SwiftyNats
//


import XCTest
@testable import SwiftyNatsTests

XCTMain([
    testCase(StringExtensionTests.allTests),
    testCase(NatsMessageTests.allTests)
])
