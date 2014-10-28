//
//  KZPredefinedEvent.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZPredefinedEvent : KZEvent {
    var eventValue : String!
    
    init(eventName:String, value:String, sessionUUID:String) {
        super.init(eventName: eventName, sessionUUID: sessionUUID)
        self.eventValue = value
    }
    
    override func serializedEvent() -> Dictionary<String, AnyObject> {
        return ["eventName" : eventName,
                "eventValue" : eventValue,
                "sessionUUID" : sessionUUID
                ]
    }
    
}
