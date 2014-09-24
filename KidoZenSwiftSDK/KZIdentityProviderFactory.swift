//
//  KZIdentityProviderFactory.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*!
    This class is a factory for identityProviders. It exposes a method that returns an 
    instance of KZWRAPv09IdentityProvider or KZADFSIdentityProvider depending on 
    the provider protocol.
*/
class KZIdentityProviderFactory
{
    class func createProvider(providerProtocol:String?, strictSSL:Bool?) -> KZIdentityProviderProtocol?
    {
        switch providerProtocol! {
        case "wrapv0.9":
            var ip = KZWRAPv09IdentityProvider()
            ip.strictSSL = strictSSL
            return ip
        default:
            var ip = KZADFSIdentityProvider()
            ip.strictSSL = strictSSL
            return ip
        }
    }
    
}
