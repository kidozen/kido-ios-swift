//
//  KZMail.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/11/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class KZMail : KZBaseService {

    /**
     * @parameters is a required dictionary with the following keys:
     *              from, to, subject, bodyHtml, bodyText
     */
    func send(parameters:Dictionary<String, String>, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.send(parameters, attachments: nil, willStartCb: willStartCb, success: success, failure: failure)
    }
    
    func send(parameters:Dictionary<String, AnyObject>, attachments:Dictionary<String, AnyObject>?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        willStartCb?()

        if let theAttachment = attachments {
            networkManager.strictSSL = self.strictSSL!
            self.networkManager.configureRequestSerializer(AFHTTPRequestSerializer() as AFHTTPRequestSerializer)
            self.networkManager.configureResponseSerializer(AFJSONResponseSerializer() as AFHTTPResponseSerializer)
            self.addAuthorizationHeader()

            self.networkManager.multipartPOST(path: "attachments", parameters: parameters, attachments:theAttachment, success: {
                [weak self](response, responseObject) in
                    var updatedParams = parameters
                    updatedParams["attachments"] = responseObject!
                
                    self!.sendEmail("", parameters: updatedParams, willStartCb: nil, success: success, failure: failure)
                
                
            }, failure: { (response, error) in
                if let outerFailure = failure {
                    outerFailure(response: response, error: error)
                }
            })
            
        } else {
            self.sendEmail("", parameters: parameters, willStartCb: nil, success: success, failure: failure)
        }
    }
    
    private func sendEmail(path:String, parameters:Dictionary<String, AnyObject>, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.networkManager.configureResponseSerializer(AFHTTPResponseSerializer())
        networkManager.strictSSL = self.strictSSL!
        self.addAuthorizationHeader()

        networkManager.POST(path: path, parameters: parameters, success:success, failure: failure)
        
    }

}