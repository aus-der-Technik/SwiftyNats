# SwiftyNats
A swift client for interacting with a [nats](http://nats.io) server.

Tested with Swift 5.4 on [![macos](https://github.com/aus-der-Technik/swifty-nats/actions/workflows/macos.yml/badge.svg?branch=main)](https://github.com/aus-der-Technik/swifty-nats/actions/workflows/macos.yml) and [![Linux](https://github.com/aus-der-Technik/swifty-nats/actions/workflows/linux.yml/badge.svg?branch=main)](https://github.com/aus-der-Technik/swifty-nats/actions/workflows/linux.yml)

## Support
Join the [#swift](https://natsio.slack.com/archives/C02D41BU0PQ) channel on nats.io Slack. 
We'll do our best to help quickly. Also feel free to drop by to just say hi. 

## Installation
Use SPM to install this packages as a dependency in your projects `Package.swift` file .
Add the dependencies like below.

```swift

// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "YourApp",
    products: [
        .executable(name: "YourApp", targets: ["YourApp"]),
    ],
    dependencies: [
        .package(name: "SwiftyNats", url: "https://github.com/aus-der-technik/swifty-nats.git", from: "2.0.1")
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

### Setting the loglevel

The default loglevel is `.error`. You can reset it to see more verbose messages. Possible
Values are `.debug`, `.info`, `.error` or `.critical`

```swift
let client = NatsClient("http://nats.server:4222")
client.config.loglevel = .info
```

### Information about the connected server

Since 2.0.2 it is possible to get the informations from the conencted server

```swift
let client = NatsClient("http://nats.server:4222")
print("\(client.serverInformation.serverName) has Version: \(client.serverInformation.version))");
```

## Why this repository 
Ray Krow build the most of the  beautiful code in his [original repository](https://github.com/rayepps/swifty-nats). 
There was not much activity since years, and times changing. I tryed to use the code from 
Version 1.3.1 but didn't get it working on linux, nor with Nats 2.1.7. So I decided to 
fork his repository and change a few little thing that it is working again. While spending 
some time in the code I realized, that I want to have a few things differently: so logging is 
one of them. 

I will maintain this package and optimise it for modern swift and most current NATS Servers. 

## Contribution
Contribution is always welcome. Just send me a pull request.


# Changelog

## 2.0.2
- Get information from the connected Server (Version, name, id, ...)

## 2.0.1 
- Test with GitHub Actions 
- Update Dockerfile to build and test on Swift 5.4 (Linux)
- Test with a real NATS-Server on macos
- Cleanup unused definitions
- Update Informations, do project care

## 2.0.0 
- Tested with NATS 2.3.4
- Introduced logging
- Updated depricated functions  

# Roadmap
See: Contribution ;) 
- Propper function description is needed


