//
//  KZSMSSender.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/8/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

public class KZSMSSender : KZBaseService {
    
    override init(endPoint: String, name: String, tokenController: KZTokenController)
    {
        super.init(endPoint: endPoint, name: name, tokenController: tokenController)
        self.configureNetworkManager()
    }
    
    func send(#message:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        var numbersOnlyString = self.name.filterNumbers()
        
        let path = "?to=" + numbersOnlyString + "&message=" + message.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        networkManager.POST(path: path, parameters: nil, success: success, failure: failure)
        
    }
    
    func status(#messageId:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()

        networkManager.GET(path: messageId, parameters: nil, success: success, failure: failure)
    }
        
    
    override func configureNetworkManager()
    {
        self.networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        self.networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        
        self.addAuthorizationHeader()
    }
}