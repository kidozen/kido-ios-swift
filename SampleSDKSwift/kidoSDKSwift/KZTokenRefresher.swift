//
//  KZTokenRefresher.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/12/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*!
    This class contains the token to be refreshed and the callbacks 
    that are used to do so.
    It directly interacts with the KZTokenController.
*/
class KZTokenRefresher : KZObject {
    
    internal var refreshUsernameCb : kzRefreshTokenCb?
    internal var refreshApplicationKeyCb : kzRefreshTokenCb?
    internal var refreshPassiveCb : kzRefreshTokenCb?
    
    var refreshCurrentToken : kzRefreshTokenCb?
    
}