//
//  KZAnalyticsUploader.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 11/20/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

/**
*   This class is in charge of uploading the analytics session when required.
*   You can also set it to upload every amount of seconds at most.
*/
class KZAnalyticsUploader : NSObject {

    private let kMaximumSecondsToUpload  : NSTimeInterval = 10
    private let kStartDate = "startDate"
    private let kSessionUUID = "sessionUUID"
    private let kBackgroundDate = "backgroundDate"
    
    private var uploading : Bool
    private var session : KZAnalyticsSession!
    private var logging : KZLogging
    private var uploadTimer : NSTimer?
    
    /// There is a timer that will try to upload all current events every maximumSecondsToUpload.
    /// Defaults to 300 seconds (5 minutes)
    var maximumSecondsToUpload : NSTimeInterval
    
    /**
        Initializer. Needs the session to be uploaded and the logging service where
        all events are going to be sent.
    
        :param: session        is what is going to be sent.
        :param: loggingService The service where the events are going to be sent.
    
    */
    init(session:KZAnalyticsSession, loggingService:KZLogging) {
        self.uploading = false

        self.session = session
        self.logging = loggingService
        self.maximumSecondsToUpload = kMaximumSecondsToUpload
        super.init()
        
        self.startTimer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didEnterBackground"), name: UIApplicationDidEnterBackgroundNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("willEnterForegroundNotification"), name: UIApplicationWillEnterForegroundNotification, object: nil)

    }
    
    private func startTimer() {
        self.uploadTimer?.invalidate()
        
        self.uploadTimer = NSTimer.scheduledTimerWithTimeInterval(self.maximumSecondsToUpload, target: self, selector: Selector("sendCurrentEvents"), userInfo: nil, repeats: true)

    }
    
    func sendCurrentEvents() {
        if (self.session.hasEvents()) {
            self.uploading  = false
            self.logging.write(object: self.session.events,
                                level: LogLevel.LogLevelInfo,
                          willStartCb: nil,
                              success: { [weak self] (response, responseObject) -> () in
                                self!.uploading = false
                                self!.session.removeSavedEvents()
                                self!.session.removeCurrentEvents()
                                self!.restartTimer()
                          }, failure: nil)
        } else {
            println("No events to send. Will try later")
            self.restartTimer()
        }
    }
    
    private func sendEvents() {
        self.uploading = true
        
        self.logging.write(object: self.session.events,
                            level: LogLevel.LogLevelInfo,
                      willStartCb: nil,
            success: { [weak self] (response, responseObject) -> () in
                self!.uploading = true
                self!.session.removeSavedEvents()
                self!.resetSessionState()
                
            }, failure:nil)
    }

    private func resetSessionState() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(kStartDate)
        userDefaults.removeObjectForKey(kSessionUUID)
        userDefaults.removeObjectForKey(kBackgroundDate)
        self.session.startNewSession()
    }
    
    private func restartTimer() {
        self.uploadTimer?.invalidate()
        self.startTimer()
    }

    func didEnterBackground() {
        if (self.uploading == false) {
            self.saveAnalyticsSessionState()
        }
    }
    
    func willEnterForegroundNotification() {
        if (self.uploading == false) {
            self.uploadEvents()
        }
    }

    
    private func uploadEvents() {
        
        let savedStartDate = NSUserDefaults.standardUserDefaults().valueForKey(kStartDate) as NSDate
        let backgroundDate = NSUserDefaults.standardUserDefaults().valueForKey(kBackgroundDate) as NSDate
    
        if (self.session.shouldUploadSession(backgroundDate: backgroundDate)) {
            let length = backgroundDate.timeIntervalSinceDate(savedStartDate)
            
            if (length > 0) {
                self.session.loadEventsFromDisk()
                self.session.logSession(Int(length))
                self.sendEvents()
            } else {
                self.session.removeCurrentEvents()
                self.resetSessionState()
            }
        } else {
            // should resume with the previous events and session.
            // We only need to remove the date when we enter to background state.
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kBackgroundDate)
        }
    }


    private func saveAnalyticsSessionState() {
        
        self.session.save()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(self.session.sessionUUID, forKey: kSessionUUID)
        userDefaults.setValue(NSDate(), forKey: kBackgroundDate)
        userDefaults.setValue(self.session.startSessionDate, forKey: kStartDate)
        
    }
}
