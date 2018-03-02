//
//  NatsClient+Events.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

extension NatsClient: NatsEvents {
    
    
    // MARK - Implement NatsEvents Protocol
    
    func on(_ event: NatsEvent, _ handler: @escaping () -> Void) {
        
        var handlerStore = self.eventHandlerStore[event]
        
        if handlerStore == nil {
            handlerStore = []
        }
        
        handlerStore?.append(handler)
        
        self.eventHandlerStore[event] = handlerStore

    }
    
    func fire(_ event: NatsEvent) {
        
        guard let handlerStore = self.eventHandlerStore[event] else { return }
 
        handlerStore.forEach { $0() }
        
    }
    
    
}
