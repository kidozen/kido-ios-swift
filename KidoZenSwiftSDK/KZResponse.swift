//
//  KZResponse.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

public struct KZResponse {
    public let urlRequestOperation : NSURLSessionDataTask?
    public let response : AnyObject?
    public let error : NSError?
    
    public init(urlRequestOperation:NSURLSessionDataTask?, response:AnyObject?, error:NSError?) {
        self.urlRequestOperation = urlRequestOperation
        self.response = response
        self.error = error
    }
    
    public init(fromSessionDataTask operation:NSURLSessionDataTask!) {
        self.urlRequestOperation = operation
        self.response = operation.response
        self.error = operation.error
    }
}
