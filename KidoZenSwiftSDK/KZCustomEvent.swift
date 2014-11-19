//
//  KZCustomEvent.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZCustomEvent : KZEvent {
    
    private var attributes : Dictionary<String, AnyObject>
    
    init(eventName:String, attributes:Dictionary<String, AnyObject>, sessionUUID:String) {
        self.attributes = attributes
        super.init(eventName: eventName, sessionUUID: sessionUUID)

    }

    required init(coder aDecoder: NSCoder) {
        self.attributes = aDecoder.decodeObjectForKey("attributes") as Dictionary<String, AnyObject>
        super.init(coder: aDecoder)
    }
    
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.attributes, forKey: "attributes")
    }

    override func serializedEvent() -> Dictionary<String, AnyObject> {
    
        var params : Dictionary<String, AnyObject>?
        
        if (self.attributes.count > 0) {
            params = [ "eventName" : self.eventName,
                      "sessionUUID" : self.sessionUUID,
                      "eventAttr" : self.attributes
                    ]
        } else {
            params = ["eventName" : self.eventName,
                "sessionUUID" : self.sessionUUID]
        }
        
        return params!
    }
    
    
}