# SwiftyNats
A maintained swift client for interacting with a [nats](http://nats.io) server working with NIO2.

![SwiftyNats Logo](./Resources/Logo@256.png)

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
        .package(name: "SwiftyNats", url: "https://github.com/aus-der-technik/swifty-nats.git", from: "2.1.1")
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

## Why does this project exist? 
Ray Krow created the basis for this project in his [original repository] (https://github.com/rayepps/swifty-nats). 
There hasn't been much activity for years, and times change, so swift do. I have tried to use his code from 
version 1.3.1, but it didn't work on Linux, or with Nats 2.1.7, or with NIO2. There was 
also a bug in his code that did not parse messages on a busy server (dropped messages). 
So I decided to fork his repository and change a few small things first to get the code working again. 
While spending some time in the code, I realized I wanted a few things different and found myself 
myself deeply into maintaining the nats swift community. 

So I commit: I will maintain this package and optimize it for modern swift and most current NATS servers. Please 
join the [#swift](https://natsio.slack.com/archives/C02D41BU0PQ) channel on nats.io Slack to discuss features and improvements with me. 


## Contribution
Contribution is always welcome. Just send me a pull request.


# Changelog

## 2.1.1
- rewrite the ChannelHandler: remove a buf that could lead into dropped messages! 

## 2.1.0
- uses NIO2 
- works with Vapor, now!
 
## 2.0.3
- supports iOS anf tvOS

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


