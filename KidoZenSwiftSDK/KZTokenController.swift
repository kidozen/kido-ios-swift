//
//  KZTokenController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

enum KZCurrentAuthentication : Int {
    case KZUsernamePassword = 0,
         KZApplicationKey,
         KZPassiveAuthentication
}

let kTimeOffset : Int = 10
let kExpiresOnKey = "ExpiresOn"

/*!
    The KZTokenController is the class in charge of managing all tokens in the SDK.
    It also knows, upon parsing the KZToken, which roles and claims the token has.
*/
class KZTokenController : KZObject {
    
    var rawAccessToken : String?
    var kzToken : String?
    var ipToken : String?
    var refreshToken : String?
    var tokenRefresher : KZTokenRefresher?
    var currentRoles : Array<String>!
    var currentClaims : Dictionary<String, String>!
    
    // Memory cache. we should set this to userDefaults or use keychain
    private var tokenCache : Dictionary<String, String>
    
    override init()
    {
        self.tokenCache =  Dictionary<String, String>()
        super.init()
    }
    
    var currentAuthentication : KZCurrentAuthentication! {
        didSet {
            switch self.currentAuthentication! {
            case .KZUsernamePassword:
                self.tokenRefresher?.refreshCurrentToken = self.tokenRefresher?.refreshUsernameCb
            case .KZApplicationKey:
                self.tokenRefresher?.refreshCurrentToken = self.tokenRefresher?.refreshApplicationKeyCb
            case .KZPassiveAuthentication:
                self.tokenRefresher?.refreshCurrentToken = self.tokenRefresher?.refreshPassiveCb
            default:
                assert(false, "Error")
            }
        }
        
    }
    
    private var futureTimestamp : Int?
    
    func updateAccessToken(token:String?, accessTokenKey:String!) {
        self.rawAccessToken = token
        self.kzToken = self.kzTokenFromRawAccessToken()
        self.tokenCache[accessTokenKey] = token
    }

    func updateIPToken(token:String?, ipTokenKey: String!) {
        self.ipToken = token
        self.tokenCache[ipTokenKey] = token
    }
    
    func updateRefreshToken(refreshToken:String!) {
        self.refreshToken = refreshToken
    }
    
    func loadTokensFromCache(forIpKey ipkey:String!, accessTokenKey:String!)
    {
        self.rawAccessToken = self.tokenCache[accessTokenKey]
        self.kzToken = self.kzTokenFromRawAccessToken()
        self.ipToken = self.tokenCache[ipkey]
    }
    
    func reset() {
        self.rawAccessToken = nil
        self.kzToken = nil
        self.ipToken = nil
    }
    
    func hasToRefreshToken() -> Bool {
        let rightNowTimestamp : Int = Int(NSDate().timeIntervalSince1970)
        return (self.futureTimestamp! - rightNowTimestamp - kTimeOffset) < 0
    }
    
    
    private func kzTokenFromRawAccessToken() -> String?
    {
        if (self.rawAccessToken? != nil) {
            return "WRAP access_token=\"" + self.rawAccessToken! + "\""
        } else {
            return nil
        }
    }
    
    func parseAndUpdateClaimsAndRoles()
    {
        self.currentClaims = Dictionary<String, String>()
        self.currentRoles = Array<String>()
        
        let parts : Array<String> = kzToken!.componentsSeparatedByString("&")
        for obj in parts {
            
            let components = obj.componentsSeparatedByString("=")
            let keys = components[0].componentsSeparatedByString("/")
            let key = keys[keys.endIndex - 1] // lastElement
            
            let value = components[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            self.currentClaims[key] = value
            
            if (key == "role") {
                self.currentRoles = components[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)?.componentsSeparatedByString(",")
            }
            
            if (currentClaims[kExpiresOnKey]? != nil) {
                self.futureTimestamp = self.currentClaims[kExpiresOnKey]!.toInt()!
            }
            
        }
        
    }
    
    

    
}
