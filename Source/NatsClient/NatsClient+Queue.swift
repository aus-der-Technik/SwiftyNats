//
//  NatsClient+Queue.swift
//  SwiftyNats
//
//  Created by Ray Krow on 3/2/18.
//

import Foundation

extension NatsClient: NatsClientQueue {
    
    var queueCount: Int {
        return self.messageQueue.count
    }
    
    func flushQueue() {
        // TODO: implement :)
    }
    
    func flushQueueAsync() {
        // TODO: implement :)
    }

}
