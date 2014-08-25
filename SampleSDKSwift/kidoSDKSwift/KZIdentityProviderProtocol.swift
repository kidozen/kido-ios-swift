//
//  KZIdentityProviderProtocol.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

typealias KZRequestTokenCompletionBlock = String? -> ()

protocol KZIdentityProviderProtocol {
    
    var strictSSL: Bool? { get set }

    
    /**
    * Use it to pass some configuration data to use later in your provider
    *
    * @param configuration
    */
    func configure(configuration:AnyObject?)
    
    /**
    * Initialization step
    *
    * @param username The user name of the user to be authenticate
    * @param password The password for the user
    * @param scope The identity scope
    */
    func initialize(username:String?, password:String?, scope:String?)
    
    /**
    * This method executes a request to the Identity Provider
    */
    func requestToken(identityProviderUrl:String?, willStartCb:kzVoidCb?, success:KZRequestTokenCompletionBlock?, failure:kzDidFailCb?)
}