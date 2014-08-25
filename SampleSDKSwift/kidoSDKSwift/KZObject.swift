//
//  KZObject.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*
* All Kidozen's objects will inherit from this class, just in case we need
* something to apply to all objects.
*/
class KZObject {
    
    /// Always implement init in base classes.
    /// There was a bug with the KZTokenController related to not implementing this
    /// initializer
    init() {
        
    }
}
