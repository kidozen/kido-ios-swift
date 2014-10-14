//
//  KZLogging.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/5/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

public enum  LogLevel : Int {
    case LogLevelVerbose = 0,
    LogLevelInfo,
    LogLevelWarning,
    LogLevelError,
    LogLevelCritical
    
}

public class KZLogging : KZBaseService {
    
    enum LogType : Int {
        case Query = 0,
            Clear,
            Write
    }
    
    private var logType : LogType {
        didSet {
            // Every time we change the logType, we should reconfigure the network manager
            // as responses are not always the same.
            configureNetworkManager()
        }
    }
    
    override init(endPoint: String!, name: String?, tokenController: KZTokenController!) {
        self.logType = .Query
        super.init(endPoint: endPoint, name: "", tokenController: tokenController)
    }

    public func write(object:Dictionary<String, AnyObject>?,
        level:LogLevel!,
        willStartCb:kzVoidCb?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.write(object, message: "", level: level, willStartCb: willStartCb, success: success, failure: failure)
    }
    
    public func write(object:Dictionary<String, AnyObject>?,
              message:String?,
                level:LogLevel!,
          willStartCb:kzVoidCb?,
              success:kzDidFinishCb?,
              failure:kzDidFailCb?)
    {
        self.logType = .Write
        
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
    
    public func query(query:String!, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.logType = .Query

        willStartCb?()
        
        let parameters = ["query" : query]
        
        networkManager.GET(path: "", parameters: query, success:success, failure: failure)
        
    }

    
    public func all(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.logType = .Query
        
        willStartCb?()
        
        networkManager.GET(path: "", parameters: nil, success:success, failure: failure)
        
    }
    
    public func clear(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.logType = .Clear
        
        willStartCb?()
        
        networkManager.DELETE(  path: "",
                            parameters: nil,
                               success: success,
                               failure: failure)
        
    }
    
    private func path(forLevel level:LogLevel, message:String?) -> String {
        var path = "?level=" + String(level.toRaw())
        
        if let m = message {
            let percentString = m.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            path += "&message=" + percentString
        }
        
        return path
        
    }

    override func configureNetworkManager()
    {
        switch (logType) {
            
        case .Query, .Clear:
            networkManager.configureResponseSerializer(AFJSONResponseSerializer())
            
        case .Write:
            // Response is not JSON, but text/plain
            networkManager.configureResponseSerializer(AFHTTPResponseSerializer())
        default:
            networkManager.configureResponseSerializer(AFJSONResponseSerializer())
            
        }
        
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        addAuthorizationHeader()
    }

}