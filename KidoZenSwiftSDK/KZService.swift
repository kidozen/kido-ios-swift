//
//  KZService.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/11/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

public class KZService : KZBaseService {
    
    override init(endPoint: String!, name: String?, tokenController: KZTokenController!)
    {
        super.init(endPoint: endPoint, name: name, tokenController: tokenController)
        self.configureNetworkManager()
    }
    
    func invokeMethod(method:String, data:AnyObject?,  willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.networkManager.POST(path: "invoke/\(method)", parameters: data, success: success, failure: failure)
    }

    func invokeMethod(method:String, data:AnyObject?, timeout:Int, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.networkManager.addHeaders(["timeout": String(timeout)])
        self.networkManager.POST(path: "invoke/\(method)", parameters: data, success: success, failure: failure)
    }

    func invokeMethodUsingAuthorization(method:String, data:AnyObject?,  willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.networkManager.addHeaders(["x-kidozen-actas" : self.bearerHeader()])
        self.networkManager.POST(path: "invoke/\(method)", parameters: data, success: success, failure: failure)
    }

    func invokeMethodUsingAuthorization(method:String, data:AnyObject?, timeout:Int, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.networkManager.addHeaders(["timeout" : String(timeout),
                                        "x-kidozen-actas" : self.bearerHeader()])
        self.networkManager.POST(path: "invoke/\(method)", parameters: data, success: success, failure: failure)
    }

    
    private func bearerHeader() -> String
    {
        let bearerHeaderString = (tokenController.ipToken! as NSString)
        let bearerHeaderData = bearerHeaderString.dataUsingEncoding(NSUTF8StringEncoding)
        let bearerHeaderBase64 = bearerHeaderData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
        
        return "Bearer \(bearerHeaderBase64)"
    }

    override func configureNetworkManager()
    {
        self.networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        self.networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        self.addAuthorizationHeader()
    }
    
}