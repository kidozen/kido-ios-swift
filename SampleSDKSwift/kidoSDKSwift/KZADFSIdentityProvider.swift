//
//  KZADFSIdentityProvider.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*!
    The instance of this class requests the IPToken using ADFS.
*/
class KZADFSIdentityProvider : KZObject, KZIdentityProviderProtocol {
    var strictSSL : Bool?
    
    private var wrapName : String!
    private var wrapPassword : String!
    private var wrapScope : String!
    private var endPoint : String!
    
    private var success : KZRequestTokenCompletionBlock?
    private var failure : kzDidFailCb?
    
    func configure(configuration:AnyObject?) {
        
    }
    
    func initialize(username:String?, password:String?, scope:String?) {
        self.wrapName = username
        self.wrapPassword = password
        self.wrapScope = scope
    }

    func requestToken(identityProviderUrl:String?, willStartCb:kzVoidCb?, success:KZRequestTokenCompletionBlock?, failure:kzDidFailCb?) {
        
        willStartCb?()
        
        self.success = success
        self.failure = failure
        
        self.endPoint = identityProviderUrl

        let request = NSMutableURLRequest(URL: NSURL(string: identityProviderUrl!)!)
        let msg = self.requestMessage()
        let length = "\(countElements(msg!))"
        
        request.addValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.HTTPMethod = "POST"
        request.HTTPBody = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let connection = NSURLConnection(request: request, delegate: self)
        connection!.start()
        
    }
    
    private func requestMessage() -> String! {
        return "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\" xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\"><s:Header><a:Action s:mustUnderstand=\"1\">http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action><a:To s:mustUnderstand=\"1\">\(self.endPoint)</a:To><o:Security s:mustUnderstand=\"1\" xmlns:o=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\"><o:UsernameToken u:Id=\"uuid-6a13a244-dac6-42c1-84c5-cbb345b0c4c4-1\"><o:Username>\(self.wrapName)</o:Username><o:Password Type=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText\">\(self.wrapPassword)</o:Password></o:UsernameToken></o:Security></s:Header><s:Body><trust:RequestSecurityToken xmlns:trust=\"http://docs.oasis-open.org/ws-sx/ws-trust/200512\"><wsp:AppliesTo xmlns:wsp=\"http://schemas.xmlsoap.org/ws/2004/09/policy\"><a:EndpointReference><a:Address>\(self.wrapScope)</a:Address></a:EndpointReference></wsp:AppliesTo><trust:KeyType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Bearer</trust:KeyType><trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType><trust:TokenType>urn:oasis:names:tc:SAML:2.0:assertion</trust:TokenType></trust:RequestSecurityToken></s:Body></s:Envelope>"
    }

    /// Delegate
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!)
    {
        self.failure?(response: nil, error: error)
    }

    func connection(connection: NSURLConnection!, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge!)
    {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            challenge.sender.useCredential(NSURLCredential(trust: challenge.protectionSpace.serverTrust), forAuthenticationChallenge: challenge)
        }
    }

    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!)
    {
        let httpResponse = response as NSHTTPURLResponse
        if (httpResponse.statusCode > 299) {
            let error = NSError(domain: "KZADFSIdentityProvider", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey:"KidoZen service returns an invalid response"])
            let kzResponse = KZResponse(urlRequestOperation: nil, response: response, error: error)
            self.failure?(response:kzResponse, error:error)
        }
    }


    func connection(connection: NSURLConnection!, didReceiveData data: NSData!)
    {
        let assertionContent = data.getAssertionContent()
        self.success?(assertionContent)
    }

}