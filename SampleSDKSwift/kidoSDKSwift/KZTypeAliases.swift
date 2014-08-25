//
//  KZTypeAliases.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/4/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

typealias kzDidFinishCb = (response: KZResponse?, responseObject: AnyObject?) -> ()
typealias kzDidFailCb = (response: KZResponse?, error: NSError?) -> ()

typealias kzVoidCb = () -> ()
typealias kzAnyObjectCb = AnyObject? -> ()

typealias kzErrorCb = NSError? -> ()

typealias kzRefreshTokenCb = (kzDidFinishCb?, kzDidFailCb?) -> ()

typealias kzDidFinishPassiveTokenCb = (token : String?, refreshToken:String?) -> ()
typealias kzDidFailPassiveTokenCb = (error: NSError?) -> ()

typealias kzDidFinishWebSocketCb = Dictionary<String, AnyObject> -> ()
