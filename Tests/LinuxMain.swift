//
//  LinuxMain.swift
//  SwiftyNats
//
//  Created by Ray Krow on 4/3/18.
//


import XCTest
@testable import SwiftyNatsTests

XCTMain([
    testCase(StringExtensionTests.allTests),
    testCase(NatsMessageTests.allTests)
])
