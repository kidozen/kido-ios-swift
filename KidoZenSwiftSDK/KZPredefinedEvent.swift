//
//  KZPredefinedEvent.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZPredefinedEvent : KZEvent {
    var eventValue : String
    
    init(eventName:String, value:String, sessionUUID:String) {
        self.eventValue = value
        super.init(eventName: eventName, sessionUUID: sessionUUID)
    }

    required init(coder aDecoder: NSCoder) {
        self.eventValue = aDecoder.decodeObjectForKey("eventValue") as String
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.eventValue, forKey: "eventValue")
    }
    
    override func serializedEvent() -> Dictionary<String, AnyObject> {
        return ["eventName" : eventName,
                "eventValue" : eventValue,
                "sessionUUID" : sessionUUID
                ]
    }
    
}
