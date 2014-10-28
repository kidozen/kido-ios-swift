//
//  KZEvent.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZEvent {
    var eventName : String!
    var sessionUUID : String!
    
    init(eventName:String, sessionUUID:String) {
        
        var chSet = NSCharacterSet(charactersInString:" -,.;:")

        self.eventName = join("", eventName.componentsSeparatedByCharactersInSet(chSet))
        self.sessionUUID = sessionUUID
    }
    
    func serializedEvent() -> Dictionary<String, AnyObject> {
        assertionFailure("Subclasses should override this method")
        return Dictionary<String,AnyObject>()
    }
    
}
