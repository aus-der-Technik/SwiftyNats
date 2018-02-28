//
//  NatsClient+Events.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//



extension NatsClient: NatsEvents {
    
    
    // MARK - Implement NatsEvents Protocol
    
    func on(_ eventType: NatsEventType, _ handler: @escaping (NatsEvent) -> Void) {
        
        var handlerStore = self.eventHandlerStore[eventType]
        
        if handlerStore == nil {
            handlerStore = []
        }
        
        handlerStore?.append(handler)

    }
    
    func fire(_ eventType: NatsEventType, _ message: String?) {
        
        guard let handlerStore = self.eventHandlerStore[eventType] else { return }
        
        let event: NatsEvent
        if let str = message {
            event = NatsEvent(type: eventType, message: str)
        } else {
            event = NatsEvent(type: eventType)
        }
 
        handlerStore.forEach { $0(event) }
        
    }
    
    func fire(_ event: NatsEventType) {
        self.fire(event, nil)
    }
    
    
}
