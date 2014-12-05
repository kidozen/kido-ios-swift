//
//  KZAnalyticsSession.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 11/19/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

let kDefaultSessionTimeout : NSTimeInterval = 5;

class KZAnalyticsSession {

    var sessionUUID : String!
    var sessionTimeOut : NSTimeInterval!
    var startSessionDate : NSDate!
    var deviceInfo : KZDeviceInfo!
    
    private var allEvents : KZEvents!
    
    var events : [Dictionary<NSObject, AnyObject>]	 {
        get {
            return self.allEvents.events
        }
    }
    
    init () {
        self.allEvents = KZEvents()
        self.sessionUUID = NSUUID().UUIDString
        self.startSessionDate = NSDate()
        self.sessionTimeOut = kDefaultSessionTimeout
        self.deviceInfo = KZDeviceInfo.sharedInstance
    }
    
    /**
        Will return whether the session events should be uploaded to the cloud, which
        depends on the sessionTimeOut.
    
        :param: backgroundDate is the date when the application was set to background.
        :returns: true if the difference is > than sessionTimeOut. false otherwise.
    */
    func shouldUploadSession(#backgroundDate:NSDate) -> Bool {
        let now = NSDate()
        return (now.timeIntervalSinceDate(backgroundDate) > self.sessionTimeOut)
    }

    /**
        Adds and event to the session.
    
        :param: event is the event that will be added.
    */
    func logEvent(#event:KZEvent) {
        self.allEvents.addEvent(event)
    }
    
    /**
        Will remove any persisted events
    */
    func removeSavedEvents() {
        self.allEvents.removeSavedEvents()
    }
    
    /**
        Saves current session with all current events.
    */
    func save() {
        self.allEvents.save()
    }
    
    /**
        Removes all previous events and starts a brand new session
    */
    func startNewSession() {
        self.allEvents = KZEvents()
        self.sessionUUID =  NSUUID().UUIDString
        self.startSessionDate = NSDate()
    }
    
    /**
        Will load previous events from disk
    */
    func loadEventsFromDisk() {
        self.allEvents = KZEvents.eventsFromDisk()
    }
    
    /**
        Will remove current in-memory events.
    */
    func removeCurrentEvents() {
        self.allEvents.removeCurrentEvents()
    }
    
    /**
        Returns whether the current session contains events
    
        :returns: true if we've got events in this session. false otherwise.
    */
    func hasEvents() -> Bool {
        return countElements(self.allEvents.events) > 0
    }
    
    
    private func eventForCurrentSessionWithLength(length:Int) -> KZEvent {
        var sessionEvent = KZSessionEvent(attributes: self.deviceInfo.properties(), sessionLength: length, sessionUUID: self.sessionUUID)
        return sessionEvent   
    }
    
    func logSession(length:Int) {
        self.logEvent(event:self.eventForCurrentSessionWithLength(length))
    }
    
}
