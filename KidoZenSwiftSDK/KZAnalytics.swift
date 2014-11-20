//
//  KZAnalytics.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZAnalytics {
    private var loggingService : KZLogging
    private var session : KZAnalyticsSession
    
    init(loggingService:KZLogging) {
        self.loggingService = loggingService
        self.session = KZAnalyticsSession()
    }
}