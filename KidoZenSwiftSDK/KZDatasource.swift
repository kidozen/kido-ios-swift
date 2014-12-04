//
//  KZDatasource.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/30/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation


// Implementation of the datasource service. 
public class KZDatasource : KZBaseService {

    override init (endPoint:String, name:String, tokenController:KZTokenController)
    {
        super.init(endPoint: endPoint, name: name, tokenController: tokenController)
        self.configureNetworkManager()
    }
    
    override func configureNetworkManager()
    {
        // Datasources request and response will always be in json.
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        
        // Whenever you change the serializer, you should set the authorizationHeader.
        self.addAuthorizationHeader()
    }
    
    // Convinience query without data.
    override public func query(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.query(data:nil, willStartCb:willStartCb, success:success, failure:failure)
    }
    
    public func query(  #data:Dictionary<String, AnyObject>?,
                    willStartCb:kzVoidCb?,
                        success:kzDidFinishCb?,
                        failure:kzDidFailCb?)
    {
        willStartCb?()
        
        networkManager.GET(path:self.name,
                          parameters:data,
                             success:success,
                             failure:failure)
    }
    
    
    override public func invoke(#willStartCb: kzVoidCb?, success: kzDidFinishCb?, failure: kzDidFailCb?) {
        self.invoke(data: nil, willStartCb: willStartCb, success: success, failure: failure)
    }
    
    
    
    public func invoke( #data: Dictionary<String, AnyObject>?,
                    willStartCb: kzVoidCb?,
                        success: kzDidFinishCb?,
                        failure: kzDidFailCb?)
    {
        
        willStartCb?()
        
        networkManager.POST(path:self.name, parameters: data, success: {
            
            (response,responseObject) in
                if let outerSuccess = success {
                    outerSuccess(response: response, responseObject: responseObject)
                }
            }
            , failure: {
                (response, error) in
                    if let outerFailure = failure {
                        outerFailure(response:response, error:error)
                    }
            })
    }

}