//
//  KZViewEvent.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZViewEvent : KZPredefinedEvent {

    override init(eventName: String, value: String, sessionUUID: String) {
        super.init(eventName:"View", value: value, sessionUUID: sessionUUID)
    }

}
