//
//  KZTypeAliases.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/4/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation
import CoreLocation

public typealias kzDidFinishCb = (response: KZResponse?, responseObject: AnyObject?) -> ()
public typealias kzDidFailCb = (response: KZResponse?, error: NSError?) -> ()

public typealias kzVoidCb = () -> ()
public typealias kzAnyObjectCb = AnyObject? -> ()

public typealias kzErrorCb = NSError? -> ()

public typealias kzRefreshTokenCb = (kzDidFinishCb?, kzDidFailCb?) -> ()

public typealias kzDidFinishPassiveTokenCb = (fullResponse : Dictionary<String, AnyObject> , token : String, refreshToken:String) -> ()
public typealias kzDidFailPassiveTokenCb = (error: NSError?) -> ()

public typealias kzDidFinishWebSocketCb = Dictionary<String, AnyObject> -> ()

public typealias kzDidFinishUpdateLocationCb = (placemark:CLPlacemark) -> ()

public typealias kzWrittenCb = (bytesWritten:Int) -> ()
