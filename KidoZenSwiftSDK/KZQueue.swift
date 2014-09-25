//
//  KZQueue.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/7/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

public class KZQueue : KZBaseService
{
    override init(endPoint: String!, name: String?, tokenController: KZTokenController!)
    {
        super.init(endPoint: endPoint, name: name, tokenController: tokenController)
        self.configureNetworkManager()
    }
    
    func enqueue(object:AnyObject?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        self.networkManager.POST(path:self.name, parameters: object, success: success, failure: failure)
    }
    
    
    func dequeue(object:AnyObject?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        self.networkManager.DELETE(path:self.name! + "/next", parameters: object, success: success, failure: failure)
    }
    
    override func configureNetworkManager()
    {
        self.networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        self.networkManager.configureResponseSerializer(AFHTTPResponseSerializer())
        
        self.addAuthorizationHeader()
    }
   
}