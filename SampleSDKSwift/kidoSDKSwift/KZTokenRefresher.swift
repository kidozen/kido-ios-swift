//
//  KZTokenRefresher.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/12/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class KZTokenRefresher : KZObject {
    
    internal var refreshUsernameCb : kzRefreshTokenCb?
    internal var refreshApplicationKeyCb : kzRefreshTokenCb?
    internal var refreshPassiveCb : kzRefreshTokenCb?
    
    var refreshCurrentToken : kzRefreshTokenCb?
    
}