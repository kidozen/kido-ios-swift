//
//  KZNetworkManager.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation
import Alamofire

public class KZNetworkManager : NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {

    private let manager : AFHTTPSessionManager!
    private let baseURLString: String?
    
    private weak var tokenController : KZTokenController?
    private var successUploadCb : kzDidFinishCb?
    private var failureUploadCb : kzDidFailCb?
    private var writtenCb : kzWrittenCb?
    
    
    private let afManager = Alamofire.Manager.sharedInstance
    
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
            afManager.session.configuration.HTTPAdditionalHeaders?[key] = value
        }
    }
    
    func configureResponseSerializer(serializer:AFHTTPResponseSerializer) {
        manager.responseSerializer = serializer
    }
    
    func configureRequestSerializer(serializer:AFHTTPRequestSerializer) {
        manager.requestSerializer = serializer
    }
    
    func cancelAllRequests() {
        self.manager.invalidateSessionCancelingTasks(true)
    }
    
    /// Perform GET operation on the corresponding endpoint.
    func GET(#path:String,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            self.manager.GET(path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), parameters: parameters, success: {
                
                [weak self] (afRequestOperation, responseObject) in
                let kzResponse = KZResponse(fromSessionDataTask: afRequestOperation)
                success?(response: kzResponse, responseObject: self?.convertToStringIfData(responseObject))
                
                }, failure: { (afRequestOperation, error) in
                    
                        let kzResponse = KZResponse(fromSessionDataTask: afRequestOperation)
                        failure?(response: kzResponse, error: error)
                  })
            }, failure: failure)
    }
    
    /// Multipart POST
    func multipartPOST(#path:String,
        parameters:Dictionary<String, AnyObject>?,
        attachments:Dictionary<String, AnyObject>?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            self.manager.POST(path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), parameters: parameters, constructingBodyWithBlock: {
                (form: AFMultipartFormData!) in
                if let params = attachments {
                    for (name, theData) in params {
                        let d : NSData = theData as NSData
                        form.appendPartWithFileData(d, name: path, fileName: path, mimeType: "application/octet-stream")
                    }
                }
                }, success: {
                    [weak self](sessionDataTask, responseObject) in
                    let kzResponse = KZResponse(fromSessionDataTask: sessionDataTask)
                    if (responseObject != nil) {
                        success?(response: kzResponse, responseObject: self?.convertToStringIfData(responseObject))
                    }
                }, failure: {
                    (sessionDataTask, error) in
                    let kzResponse = KZResponse(fromSessionDataTask: sessionDataTask)
                    failure?(response: kzResponse, error:error)
            })
            }, failure: failure)
    }
    
    func uploadFile(#path:String, data:NSData, writtenCb:kzWrittenCb?, success:kzDidFinishCb?, failure:kzDidFailCb?) {
        self.updateTokenIfRequired( {
            self.successUploadCb = success
            self.failureUploadCb = failure
            self.writtenCb = writtenCb
            
            // Manually uploding the file... 
            // Dunno why it doesn't work with AF
            let url = NSURL(string: path.stringByDeletingLastPathComponent, relativeToURL: self.manager.baseURL)
            var request = NSMutableURLRequest(URL: url!)
            
            request.HTTPBodyStream = NSInputStream(data: data)
            request.HTTPMethod = "POST"
            request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.setValue(path.onlyFilename()!, forHTTPHeaderField: "x-file-name")
            request.setValue(self.tokenController?.kzToken, forHTTPHeaderField: "Authorization")
            
            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
            connection.start()

            }, failure: failure)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        let httpResponse = response as NSHTTPURLResponse
        let kzResponse = KZResponse(urlRequestOperation: nil, response: response, error: nil)

        if (httpResponse.statusCode == 200) {
            self.successUploadCb?(response: kzResponse, responseObject: nil)
        } else if (httpResponse.statusCode > 300) {
            self.failureUploadCb?(response:kzResponse, error:nil)
        }
    }
    
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.failureUploadCb?(response:nil, error:error)
    }

    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        self.writtenCb?(bytesWritten: bytesWritten)
    }
    
    func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if (challenge.protectionSpace.authenticationMethod! == NSURLAuthenticationMethodServerTrust) {
            if (self.strictSSL) {
                let protectionSpace = challenge.protectionSpace
                let credential = NSURLCredential(forTrust: protectionSpace.serverTrust)
                challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
            } else {
                challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
            }
        }
    }
    


    /// Perform POST operation on the corresponding endpoint.
    func POST(#path:String,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL

            self.manager.POST(path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), parameters: parameters,
                success: {
                    [weak self](operation, responseObject) in
                    let kzResponse = KZResponse(fromSessionDataTask: operation)
                    success?(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                }, failure: {
                    (operation, error) in
                    let kzResponse = KZResponse(fromSessionDataTask: operation)
                    failure?(response: kzResponse, error:error)
                   })
            }, failure: failure)
        
    }
    
    func DELETE(#path:String,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            
            self.manager.DELETE(path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), parameters: parameters,
                success: {
                    [weak self](operation, responseObject) in
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        success?(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                }, failure: {
                    (operation, error) in
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        failure?(response: kzResponse, error:error)
                   })
            }, failure: failure)
        
    }
    
    
    /// Perform PUT operation on the corresponding endpoint.
    func PUT(#path:String,
        parameters:AnyObject?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.updateTokenIfRequired({
            
            self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL
            
            self.manager.PUT(path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), parameters: parameters,
                success: {
                    [weak self] (operation, responseObject) in
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        success?(response: kzResponse, responseObject: self!.convertToStringIfData(responseObject))
                }, failure: {
                    (operation, error) in
                        let kzResponse = KZResponse(fromSessionDataTask: operation)
                        failure?(response: kzResponse, error:error)
                   })
            }, failure: failure)
        
    }
    
    func download(#url:NSURL, destination:String, progressCb:(Int64) -> Void, successCb:kzDidFinishCb, failureCb: kzDidFailCb) {
        
        var request = NSMutableURLRequest(URL:url)
        
        request.addValue(self.tokenController?.kzToken, forHTTPHeaderField: "Authorization")
        
        var p : NSProgress?
        self.manager.securityPolicy.allowInvalidCertificates = !self.strictSSL

        let downloadTask = self.manager.downloadTaskWithRequest(request, progress: &p, destination: { (url, urlResponse) in
                return NSURL(fileURLWithPath: destination)
            
            }, completionHandler: { (urlResponse, url, error) in
                
                let response = KZResponse(urlRequestOperation: nil, response: urlResponse, error: error)
                if error != nil {
                    failureCb(response:response, error: error)
                } else {
                    successCb(response: response, responseObject: urlResponse)
                }
        })

        self.manager.setDownloadTaskDidWriteDataBlock { (session, downloadTask, bWritten, totalBytesWritten, expectedToWrite) -> Void in
            progressCb(totalBytesWritten)
        }
        
        downloadTask.resume()
        

    }
    
    private func convertToStringIfData(data: AnyObject?) -> AnyObject! {
        let theData = data as? NSData
        
        if (theData != nil) {
            return NSString(data: theData!, encoding: NSUTF8StringEncoding)
        } else {
            return data
        }
    }
    
    private func updateTokenIfRequired(#cb:kzVoidCb, failure:kzDidFailCb?) {
        
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
    
    internal func addAuthorizationHeader(token:String) {
        manager.requestSerializer.setValue(token, forHTTPHeaderField: "Authorization")
        afManager.session.configuration.HTTPAdditionalHeaders = ["Authorization": token]

    }
    
}