//
//  KZNotification.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/8/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation


class KZNotification : KZBaseService {
    private let kUniqueIdentificationFilename = "kUniqueIdentificationFilename"
    private let uniqueIdentifier : String?

    override init(endPoint: String!, name: String?, tokenController: KZTokenController!)
    {
        super.init(endPoint: endPoint, name: name, tokenController: tokenController)
        self.tokenController = tokenController
        
        self.uniqueIdentifier = self.uniqueIdentification()
        self.configureNetworkManager()
    }
    
    func subscribe(deviceWithToken deviceToken:String, channel:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.addAuthorizationHeader()

        let path = "subscriptions/\(self.name!)/\(channel)"
        let params = ["platform": "apns",
                    "subscriptionId": deviceToken,
                    "deviceId" :self.uniqueIdentifier!]
        
        networkManager.POST(path: path,
                        parameters: params,
                           success: success,
                           failure: failure)
    }
  
    func push(notification:Dictionary<String, AnyObject>, channel:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.addAuthorizationHeader()

        let path = "push/\(self.name!)/\(channel)"
        networkManager.POST(path: path,
            parameters: notification,
            success: success,
            failure: failure)
    }
  
    func getSubscriptions(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.addAuthorizationHeader()

        let path = "devices/\(self.uniqueIdentifier!)/\(self.name!)"
        networkManager.GET(  path: path,
                         parameters: nil,
                            success: success,
                            failure: failure)
    }

    
    func getApplicationChannels(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.addAuthorizationHeader()

        let path = "channels/\(self.name!)"
        networkManager.GET(  path: path,
            parameters: nil,
            success: success,
            failure: failure)
    }
    
    
    func unsubscribe(deviceWithToken deviceToken:String, channel:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.addAuthorizationHeader()

        let path = "subscriptions/\(self.name!)/\(channel)/\(deviceToken)"
        
        networkManager.DELETE(path: path,
                            parameters: nil,
                            success: success,
                            failure: failure)
    }
    
    override func configureNetworkManager()
    {
        self.networkManager.configureRequestSerializer(AFJSONRequestSerializer() as AFHTTPRequestSerializer)
        self.networkManager.configureResponseSerializer(AFHTTPResponseSerializer() as AFHTTPResponseSerializer)
    }
    
    private func uniqueIdentification() -> String
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        var uniqueId = userDefaults.valueForKey(kUniqueIdentificationFilename) as? String
        
        if (uniqueId == nil) {
            uniqueId = NSUUID().UUIDString
            userDefaults.setValue(uniqueId, forKey: kUniqueIdentificationFilename)
            userDefaults.synchronize()
        }
        
        return uniqueId!
    }
}