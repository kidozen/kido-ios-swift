//
//  KZLogging.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/5/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

enum  LogLevel : Int {
    case LogLevelVerbose = 0,
    LogLevelInfo,
    LogLevelWarning,
    LogLevelError,
    LogLevelCritical
    
}

class KZLogging : KZBaseService {
    
    override init(endPoint: String!, name: String?, tokenController: KZTokenController!) {
        super.init(endPoint: endPoint, name: nil, tokenController: tokenController)
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        self.configureNetworkManager()
    }

    private func path(forLevel level:LogLevel, messageTitle:String?) -> String {
        var path = "?level=" + String(level.toRaw())
        
        if let m = messageTitle {
            let percentString = m.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            path += "&message=" + percentString
        }
        
        return path
        
    }
    
    func write(object:Dictionary<String, AnyObject>?,
        level:LogLevel!,
        willStartCb:kzVoidCb?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.write(object, messageTitle: "", level: level, willStartCb: willStartCb, success: success, failure: failure)
    }
    
    func write(object:Dictionary<String, AnyObject>?,
              messageTitle:String?,
                level:LogLevel!,
          willStartCb:kzVoidCb?,
              success:kzDidFinishCb?,
              failure:kzDidFailCb?)
    {
        // Response is not JSON, but text/plain
        networkManager.configureResponseSerializer(AFHTTPResponseSerializer())
        willStartCb?()
        
        let path = self.path(forLevel: level, messageTitle: messageTitle)
        
        networkManager.POST(path: path, parameters: object, success: {
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
    
    func query(query:String!, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?) {
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        willStartCb?()
        
        let parameters = ["query" : query]
        
        networkManager.GET(path: "", parameters: query, success:success, failure: failure)
        
    }

    
    func all(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        willStartCb?()
        
        networkManager.GET(path: "", parameters: nil, success:success, failure: failure)
        
    }
    
    func clear(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        willStartCb?()
        
        networkManager.DELETE(  path: "",
                            parameters: nil,
                               success: success,
                               failure: failure)
        
    }

    override func configureNetworkManager()
    {
        addAuthorizationHeader()
    }

}