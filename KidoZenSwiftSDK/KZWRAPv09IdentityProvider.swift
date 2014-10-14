//
//  KZWRAPv09IdentityProvider.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*!
    The instance of this class requests the IPToken using the 
    Web Resource Authorization Protocol v0.9.
*/
class KZWRAPv09IdentityProvider : KZObject, KZIdentityProviderProtocol {
 
    var strictSSL: Bool!
    
    var wrapName : String!
    var wrapPassword : String!
    var wrapScope : String!
    
    private var networkManager : KZNetworkManager?
    
    
    func configure(configuration:AnyObject?) {
        
    }
    
    func initialize(#username:String, password:String, scope:String) {
        wrapName = username
        wrapPassword = password
        wrapScope = scope
    }
    
    func requestToken(#identityProviderUrl:String, willStartCb:kzVoidCb?, success:KZRequestTokenCompletionBlock?, failure:kzDidFailCb?) {
            
        networkManager = KZNetworkManager(baseURLString: identityProviderUrl, strictSSL: strictSSL, tokenController:nil)
        networkManager?.configureResponseSerializer(AFHTTPResponseSerializer())

        let parameters = [  "wrap_name" : wrapName!,
                        "wrap_password" : wrapPassword!,
                           "wrap_scope" : wrapScope!]
        
        willStartCb?()
        networkManager!.POST(path: "", parameters:parameters, success:{
            [weak self](operation, responseObject) in
                let theDataString = responseObject as String
            
                if let outerSuccess = success {
                    outerSuccess(theDataString.tag("Assertion"))
                }
            
            }, failure: {
                (operation,error) in
                if let outerFailure = failure {
                    outerFailure(response: operation, error: error)
                }
            });
    }
   
    
}