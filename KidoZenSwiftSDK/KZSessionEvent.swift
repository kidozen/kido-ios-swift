//
//  KZSessionEvent.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/28/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZSessionEvent : KZCustomEvent {
    
    init(attributes:Dictionary<String, AnyObject>, sessionLength:Int, sessionUUID:String) {
        var attr : Dictionary<String, AnyObject>
        attr = attributes
        attr["sessionLength"] = sessionLength
        attr["platform"] = "iOS"
        
        super.init(eventName: "user-session", attributes: attr, sessionUUID: sessionUUID)
    
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}