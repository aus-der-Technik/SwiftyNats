

# SwiftyNats
A swift client for interacting with a [nats](http://nats.io) server.

[![Build Status](https://travis-ci.org/raykrow/swifty-nats.svg?branch=master)](https://travis-ci.org/raykrow/swifty-nats)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/raykrow/swifty-nats/blob/master/LICENSE)
[![Swift4](http://img.shields.io/badge/swift-4.1-brightgreen.svg)](https://swift.org)

### TODO
- Save `connect_urls` property from INFO response and use it later when attempting to reconnect
- In `publish` method make the payload optional. Its ok to send 0 count and no payload `PUB swift.test 0\r\n\r\n`
- Support subscribing to a queue group `SUB swift.test G1 11\r\n`
- Configurable max queue size, default 100
- Configurable message encoding, default UTF-8
- When trying to reconnect to the server, wait 2 seconds between retries, configurable
- Add a `reconnecting` event
