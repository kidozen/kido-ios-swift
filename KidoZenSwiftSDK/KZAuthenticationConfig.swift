//
//  KZAuthenticationConfig.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

let kEndPointKey = "endpoint";
let kProtocolKey = "protocol";


/*!
    This class models the response in the 'authConfig' key, that comes in 
    configuration request which is obtained at https://TENANT_URL/publicapi/apps?name=APPNAME
*/
public class KZAuthenticationConfig : KZObject {
    
    var applicationScope : String
    var authServiceScope : String
    var authServiceEndpoint : String
    var oauthTokenEndpoint : String
    var signInUrl : String
    
    private var identityProviders : Dictionary<String,Dictionary<String, String>>
    
    
    init(fromDictionary dictionary: Dictionary<String, AnyObject>) {
        applicationScope = (dictionary["applicationScope"] as AnyObject?) as String
        authServiceScope = (dictionary["authServiceScope"] as AnyObject?) as String
        authServiceEndpoint = (dictionary["authServiceEndpoint"] as AnyObject?) as String
        oauthTokenEndpoint = (dictionary["oauthTokenEndpoint"] as AnyObject?) as String
        signInUrl = (dictionary["signInUrl"] as AnyObject?) as String
        identityProviders = (dictionary["identityProviders"] as AnyObject?) as Dictionary<String,Dictionary<String, String>>
        super.init()
    }
    
    func protocolFor(provider: String) -> String? {
        
        let protocolDictionary = identityProviders[provider]
        
        return protocolDictionary?[kProtocolKey] as String?

    }
    
    func endPointFor(provider:String) -> String? {
        let protocolDictionary = identityProviders[provider]
        return protocolDictionary?[kEndPointKey] as String?
    }
    
}