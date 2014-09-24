//
//  KZUser.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation


class KZUser : KZObject {
    
    let claims : Dictionary<String, String>
    let roles : Array<String>

    init(claims:Dictionary<String, String>, roles:Array<String>) {
        self.claims = claims
        self.roles = roles
        super.init()
    }
    
    func isInRole(role:NSString?) -> Bool {
        for aRole in self.roles {
            if (aRole == role) {
                return true
            }
        }
        return false
    }
}

