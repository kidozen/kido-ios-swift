//
//  KZAnalytics.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

public class KZAnalytics {
    
    private var loggingService : KZLogging
    private var session : KZAnalyticsSession
    private var sessionUploader : KZAnalyticsUploader?
    
    init(loggingService:KZLogging) {
        self.loggingService = loggingService
        self.session = KZAnalyticsSession()
    }
    
    /**
        By Default, analytics are disabled. Enable it when you
    */
    func enableAnalytics() {
        self.sessionUploader = KZAnalyticsUploader(session: self.session, loggingService: self.loggingService)
        KZDeviceInfo.sharedInstance.enableGeoLocation()
    }
    
    func disableAnalytics() {
        self.sessionUploader = nil
    }

    /**
        This method will erase all current and saved analytics and start over
    */
    func resetAnalytics() {
        self.session.removeSavedEvents()
        self.session.removeCurrentEvents()
        self.session.startNewSession()
    }

    /**
        Tags a click with the corresponding name. It'll be reflected in your server.
    
        :param: buttonName The name of the button you just clicked/tapped.
    */
    func tagClick(#buttonName:String) {
        var clickEvent = KZClickEvent(value: buttonName, sessionUUID: self.session.sessionUUID)
        self.session.logEvent(event: clickEvent)
    }

    /**
        Tags a view with the corresponding name.
    
        :param: viewName should be something that identifies a particular view.
    */
    func tagView(#viewName:String) {
        var viewEvent = KZViewEvent(value: viewName, sessionUUID: self.session.sessionUUID)
        self.session.logEvent(event: viewEvent)
    }
    
    /**
        Tags a custom event, created by the developer. For example, it could be something
        like "taskCreated".
    
        :param: customEventName is the name that identifies the event.
        :param: attributes      is a dictionary with attributes that corresponds to the event,
                                for example, @{"Category" : "Critical"}
    */
    func tagEvent(#customEventName:String, attributes:Dictionary<String, AnyObject>) {
        
        var customEvent = KZCustomEvent(eventName: customEventName,
                                       attributes: attributes,
                                      sessionUUID: self.session.sessionUUID)
        
        self.session.logEvent(event: customEvent)

    }
}
