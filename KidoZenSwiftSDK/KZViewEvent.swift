//
//  KZViewEvent.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZViewEvent : KZPredefinedEvent {

    init(value: String, sessionUUID: String) {
        super.init(eventName:"View", value: value, sessionUUID: sessionUUID)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
