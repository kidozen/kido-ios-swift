//
//  KZResponse.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

struct KZResponse {
    let urlRequestOperation : NSURLSessionDataTask?
    let response : AnyObject?
    let error : NSError?
    
    init(urlRequestOperation:NSURLSessionDataTask?, response:AnyObject?, error:NSError?) {
        self.urlRequestOperation = urlRequestOperation
        self.response = response
        self.error = error
    }
    
    init(fromSessionDataTask operation:NSURLSessionDataTask!) {
        self.urlRequestOperation = operation
        self.response = operation.response
        self.error = operation.error
    }
}
