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
    }

    private func path(forLevel level:LogLevel, message:String?) -> String {
        var path = "?level=" + String(level.toRaw())
        
        if let m = message {
            let percentString = m.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            path += "&message=" + percentString
        }
        
        return path
        
    }
    
    func write(object:AnyObject?,
        level:LogLevel!,
        willStartCb:kzVoidCb?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.write(object, message: "", level: level, willStartCb: willStartCb, success: success, failure: failure)
    }
    
    func write(object:AnyObject?,
              message:String?,
                level:LogLevel!,
          willStartCb:kzVoidCb?,
              success:kzDidFinishCb?,
              failure:kzDidFailCb?)
    {
        // Response is not JSON, but text/plain
        networkManager.configureResponseSerializer(AFHTTPResponseSerializer())
        self.configureNetworkManager()

        willStartCb?()
        
        
        let path = self.path(forLevel: level, message: message)
        
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

    
    func all(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        self.configureNetworkManager()

        willStartCb?()
        
        networkManager.GET(path: "", parameters: nil, success:success, failure: failure)
        
    }
    
    func clear(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())

        self.configureNetworkManager()
        
        willStartCb?()
        
        networkManager.DELETE(  path: "",
                            parameters: nil,
                               success: success,
                               failure: failure)
        
    }

    override func configureNetworkManager()
    {
        addAuthorizationHeader()
        networkManager.strictSSL = self.strictSSL!
    }

}