//
//  NatsClient+Queue.swift
//  SwiftyNats
//
//  Created by Ray Krow on 3/2/18.
//

import Foundation

extension NatsClient: NatsQueue {
    
    var queueCount: Int {
        return self.messageQueue.count
    }
    
    private var waitTimeBetweenQueueCheck: UInt32 {
        return UInt32(0.10)
    }
    
    open func flushQueue(maxWait: TimeInterval? = nil) throws {
        
        let startTimestamp = Date().timeIntervalSinceNow
        
        let group = DispatchGroup()
        group.enter()
        
        var error: NatsTimeoutError?
        
        DispatchQueue.global(qos: .default).async { [weak self] in

            guard let s = self else { group.leave(); return }
            while true {
                if s.messageQueue.count == 0 {
                    break
                }
                if let mw = maxWait {
                    if Date().timeIntervalSinceNow - startTimestamp > mw {
                        error = NatsTimeoutError("Could not handle all messages in queue before max time limit reached")
                        break
                    }
                }
                sleep(s.waitTimeBetweenQueueCheck)
            }
            group.leave()
        }
        
        self.disconnect()
        
        group.wait()
        
        if let e = error {
            throw e
        }
        
    }
    
    open func flushQueue() {
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            // Wait for server to respond with +OK
            guard let s = self else { group.leave(); return }
            while true {
                if s.messageQueue.count == 0 {
                    break
                }
                sleep(s.waitTimeBetweenQueueCheck)
            }
            group.leave()
        }
        
        self.disconnect()
        
        group.wait()
        
    }

}
