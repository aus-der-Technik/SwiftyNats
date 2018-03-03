//
//  NatsClient+Events.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

extension NatsClient: NatsEvents {
    
    // MARK - Implement NatsEvents Protocol
    
    open func on(_ events: [NatsEvent], _ handler: @escaping (NatsEvent) -> Void) {
        
        for e in events {
            on(e, handler)
        }

    }
    
    open func on(_ event: NatsEvent, _ handler: @escaping (NatsEvent) -> Void) {
        
        var handlerStore = self.eventHandlerStore[event]
        
        if handlerStore == nil {
            handlerStore = []
        }
        
        handlerStore?.append(handler)
        
        self.eventHandlerStore[event] = handlerStore
        
    }
    
    // MARK - Implement internal methods
    
    internal func fire(_ event: NatsEvent) {
        
        guard let handlerStore = self.eventHandlerStore[event] else { return }
 
        handlerStore.forEach { $0(event) }
        
        if [.response, .error].contains(event) {
            self.eventHandlerStore[event] = []
        }
        
    }
    
}
