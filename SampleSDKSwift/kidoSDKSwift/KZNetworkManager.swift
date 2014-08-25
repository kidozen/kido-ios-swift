//
//  KZNetworkManager.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class KZNetworkManager {
    private let manager : AFHTTPSessionManager!
    private let baseURLString: String?
    
    private weak var tokenController : KZTokenController?
    
    // You can change whether we want to allow invalid SSL certificates.
    var strictSSL = true
    
    init(baseURLString:String, strictSSL:Bool, tokenController:KZTokenController?) {
        self.strictSSL = strictSSL
        self.baseURLString = baseURLString
        self.tokenController = tokenController
        
        let baseUrl = NSURL(string: baseURLString)
        
        manager = AFHTTPSessionManager(baseURL: baseUrl)
        
        // Log level -- Should only be in debug.
        AFNetworkActivityLogger.sharedLogger().level = .AFLoggerLevelDebug
        AFNetworkActivityLogger.sharedLogger().startLogging()
    }
    
    func addHeaders(headers:Dictionary<String, String>) {
        for (key, value) in headers {
            manager.requestSerializer.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    func configureResponseSerializer(serializer:AFHTTPResponseSerializer?) {
        manager.responseSerializer = serializer?
    }
    
    func configureRequestSerializer(serializer:AFHTTPRequestSerializer?) {
        manager.requestSerializer = serializer?
    }
    
    /// Perform GET operation on the corresponding endpoint.
    func GET(#path:String?,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            self.manager.GET(path, parameters: parameters, success: {
                [weak self] (afRequestOperation, responseObject) in
                
                if let outerSuccess = success {
                    let kzResponse = KZResponse(fromSessionDataTask: afRequestOperation)
                    outerSuccess(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                }
                
                }, failure: {
                    (afRequestOperation, error) in
                    
                    if let outerFailure = failure {
                        let kzResponse = KZResponse(fromSessionDataTask: afRequestOperation)
                        outerFailure(response: kzResponse, error: error)
                    }
                  })
            }, failure: failure)
    }
    
    /// Multipart POST
    func multipartPOST(#path:String,
        parameters:Dictionary<String, AnyObject>,
        attachments:Dictionary<String, AnyObject>,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            self.manager.POST(path, parameters: nil, constructingBodyWithBlock: {
                (form: AFMultipartFormData!) in
                
                for (name, theData) in attachments {
                    form.appendPartWithFileData(theData as NSData, name: name, fileName: name, mimeType: "application/octet-stream")
                }
                
                }, success: {
                    [weak self](sessionDataTask, responseObject) in
                    if let outerSuccess = success {
                        let kzResponse = KZResponse(fromSessionDataTask: sessionDataTask)
                        outerSuccess(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                    }
                }, failure: {
                    (sessionDataTask, error) in
                    if let outerFailure = failure {
                        let kzResponse = KZResponse(fromSessionDataTask: sessionDataTask)
                        outerFailure(response: kzResponse, error:error)
                    }
            })
            }, failure: failure)
    }
    
    
    /// Perform POST operation on the corresponding endpoint.
    func POST(#path:String?,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL

            self.manager.POST(path, parameters: parameters,
                success: {
                    [weak self](operation, responseObject) in
                    if let outerSuccess = success {
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        outerSuccess(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                    }
                }, failure: {
                    (operation, error) in
                    if let outerFailure = failure {
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        outerFailure(response: kzResponse, error:error)
                    }
                   })
            }, failure: failure)
        
    }
    
    func DELETE(#path:String?,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            
            self.manager.DELETE(path, parameters: parameters,
                success: {
                    [weak self](operation, responseObject) in
                    if let outerSuccess = success {
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        outerSuccess(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                    }
                }, failure: {
                    (operation, error) in
                    if let outerFailure = failure {
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        outerFailure(response: kzResponse, error:error)
                    }
                   })
            }, failure: failure)
        
    }
    
    
    /// Perform PUT operation on the corresponding endpoint.
    func PUT(#path:String?,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            
            self.manager.PUT(path, parameters: parameters,
                success: {
                    [weak self] (operation, responseObject) in
                    if let outerSuccess = success {
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        outerSuccess(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                    }
                }, failure: {
                    (operation, error) in
                    if let outerFailure = failure {
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        outerFailure(response: kzResponse, error:error)
                    }
                   })
            }, failure: failure)
        
    }
    
    private func convertToStringIfData(data: AnyObject) -> AnyObject! {
        let theData = data as? NSData
        
        if (theData != nil) {
            return NSString(data: theData!, encoding: NSUTF8StringEncoding)
        } else {
            return data
        }
    }
    
    private func updateTokenIfRequired(cb:kzVoidCb, failure:kzDidFailCb?) {
        
        if let tc = self.tokenController {
            
            if (tc.hasToRefreshToken()) {
                tc.tokenRefresher?.refreshCurrentToken?({
                    (response, responseObject) in
                        cb()
                    }, failure)
            } else {
                cb()
            }
            
        } else {
            cb()
        }
    }
    
    internal func addAuthorizationHeader(token:String?) {
        if let theToken = token {
            manager.requestSerializer.setValue(theToken, forHTTPHeaderField: "Authorization")
        }
    }
    
}