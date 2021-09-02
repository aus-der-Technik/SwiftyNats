//
//  NatsClient+ServerInfo.swift
//  by aus der Technik, 02.09.21.
//

import Foundation

extension NatsClient {
    
    /// Information about the connected server
    ///
    /// The struct holfds getters that provide some information about
    /// the server that is currently conneced.
    ///
    ///  Properties detail information can get from `NatsServer`.
    ///  - returns
    ///     - NatsServer
    ///     - `nil` if not connected
    ///
    public var serverInformation: NatsServer? { get { return self.server } }
}
