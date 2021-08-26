

# SwiftyNats
A swift client for interacting with a [nats](http://nats.io) server.
Tested with Swift 5.4 on macOS and Linux

[![Build Status](https://travis-ci.org/raykrow/swifty-nats.svg?branch=master)](https://travis-ci.org/raykrow/swifty-nats)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/raykrow/swifty-nats/blob/master/LICENSE)
[![Swift5](http://img.shields.io/badge/swift-5.4-brightgreen.svg)](https://swift.org)

## Why this repository 
Ray Krow build the most of the  beautiful code in his [original repository](https://github.com/rayepps/swifty-nats). There was not much activity since years, and times changing. I tryed to use the code from Version 1.3.1 but didn't get it working on linux, nor with Nats 2.1.7. So I decided to fork his repository and change a few little thing that it is working again. While spending some time in the code I realized, that I want to have a few things differently: so logging is one of them. 

I will maintain this code and optimzie it for modern swift and most current NATS Servers. A roadmap will follow. 


## Installation
Only uses SPM to install. Add the dependencies like below.

```swift

// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "YourApp",
    products: [
        .library(name: "YourApp", targets: ["YourApp"])
    ],
    dependencies: [
        .package(name: "SwiftyNats", url: "https://github.com/petershaw/swifty-nats.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: ["SwiftyNats"]
        ),
    ]
)

```

## Basic Usage
```swift

import SwiftyNats

let client = NatsClient("http://nats.server:4222")

client.on(.connect) { _ in
    print("Client connected")
}

try? client.connect()

client.subscribe("foo.bar") { message in
    print("payload: \(message.payload)")
    print("size: \(message.byteCount)")
    print("reply subject: \(message.replySubject.subject)")
}

client.publish("this event happened", to: "foo.bar")

```

### Set the loglevel

```swift
let client = NatsClient("http://nats.server:4222")
client.config.loglevel = .info
```
