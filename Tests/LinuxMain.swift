//
//  LinuxMain.swift
//  SwiftyNats
//
//  Created by Ray Krow on 4/3/18.
//


#if os(Linux)

import XCTest
@testable import SwiftyNatsTests

XCTMain([
    testCase(StringExtensionTests.allTests),
])

#endif
