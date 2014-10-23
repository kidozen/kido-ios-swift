//
//  KZConfiguration.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/7/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class KZConfiguration : KZBaseService {
    override init(endPoint: String!, name: String?, tokenController: KZTokenController!)
    {
        super.init(endPoint: endPoint, name: name, tokenController: tokenController)
        self.configureNetworkManager()
    }
    
    /**
    *
    */
    func save(object: Dictionary<String, String>?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        
        self.networkManager.configureResponseSerializer(AFHTTPResponseSerializer())
        self.addAuthorizationHeader()
        
        self.networkManager.POST(path:self.name, parameters: object, success: success, failure: failure)
    }
    
    func get(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.networkManager.configureResponseSerializer(AFJSONResponseSerializer() as AFHTTPResponseSerializer)
        self.addAuthorizationHeader()

        self.networkManager.GET(path:self.name, parameters: nil, success: success, failure: failure)
    }
    
    func remove(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.networkManager.configureResponseSerializer(AFJSONResponseSerializer() as AFHTTPResponseSerializer)
        
        self.addAuthorizationHeader()
        self.networkManager.DELETE(path:self.name, parameters: nil, success: success, failure: failure)
    }
    
    
    func all(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.networkManager.configureResponseSerializer(AFJSONResponseSerializer() as AFHTTPResponseSerializer)
        
        self.addAuthorizationHeader()
        self.networkManager.GET(path:"", parameters: nil, success: success, failure: failure)
    }
    
    override func configureNetworkManager()
    {
        self.networkManager.configureRequestSerializer(AFJSONRequestSerializer() as AFHTTPRequestSerializer)
        self.networkManager.configureResponseSerializer(AFJSONResponseSerializer() as AFHTTPResponseSerializer)
        
        self.addAuthorizationHeader()
    }

}