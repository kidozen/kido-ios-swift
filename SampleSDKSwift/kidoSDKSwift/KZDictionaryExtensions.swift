//
//  KZDictionaryExtensions.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/8/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

extension Dictionary {

    func asQueryString() -> String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString: String = "\(key)"
            let valueString: String = "\(value)"
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return join("&", parts)
    }
    
}