//
//  KZDeviceInfo.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 11/20/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

private let _singletonInstance = KZDeviceInfo()

class KZDeviceInfo {
    
    init() {
        
    }
    
    class var sharedInstance : KZDeviceInfo {
        return _singletonInstance
    }
    
    func properties() -> Dictionary<String, AnyObject> {
        return ["test":"value"]
    }
    
}