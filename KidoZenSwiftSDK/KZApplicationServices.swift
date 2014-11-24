//
//  KZApplicationServices.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/30/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*!
    This class groups all services related code and classes.
    It provides convinient methods to get new instances for the following services:

        - Datasource
        - Configuration
        - Queue
        - Storage
        - SMS
        - Service
    
    It also has Logging, Notification and Mail properties.

*/
class KZApplicationServices {

    private var applicationConfiguration : KZApplicationConfiguration
    private weak var tokenController : KZTokenController?
    private var strictSSL : Bool
    
    
    var loggingService : KZLogging!
    var eventsLoggerService : KZLogging!
    var notificationsService : KZNotification!
    var mailService : KZMail!
    var analytics : KZAnalytics!
    
    init( applicationConfiguration:KZApplicationConfiguration,
                   tokenController:KZTokenController,
                         strictSSL:Bool)
    {
        self.applicationConfiguration = applicationConfiguration
        self.tokenController = tokenController
        self.strictSSL = strictSSL
        
        self.initializeLogging()
        self.initializeMail()
        self.initializePushNotifications()
        self.initializeAnalytics()
        
    }
    
    func datasource(#name:String) -> KZDatasource
    {
        var endPoint = applicationConfiguration.datasource!.stringByAppendingString("/") // validate it ends with '/'
        var service = KZDatasource(endPoint: endPoint, name: name, tokenController:tokenController!)
        service.strictSSL = strictSSL
        return service
    }
    
    func configuration(#name:String) -> KZConfiguration
    {
        var endPoint = applicationConfiguration.config!
        var service = KZConfiguration(endPoint: endPoint, name: name, tokenController: tokenController!)
        service.strictSSL = strictSSL
        return service
    }
    
    func queue(#name:String) -> KZQueue
    {
        var endPoint = applicationConfiguration.queue!
        var service = KZQueue(endPoint: endPoint, name: name, tokenController: tokenController!)
        service.strictSSL = strictSSL
        return service
    }
    
    func storage(#name:String) -> KZStorage
    {
        var endPoint = applicationConfiguration.storage!
        var service = KZStorage(endPoint: endPoint, name: name, tokenController: tokenController!)
        service.strictSSL = strictSSL
        return service
    }
    
    func SMSSender(#number:String) -> KZSMSSender
    {
        var endPoint = applicationConfiguration.sms!
        var sender = KZSMSSender(endPoint: endPoint, name: number, tokenController: tokenController!)
        sender.strictSSL = strictSSL
        return sender
    }
    
    func LOBServiceWithName(#name:String) -> KZService
    {
        var endPoint = "\(self.applicationConfiguration.url!)api/services/\(name)/"
            
        var service = KZService(endPoint: endPoint, name: name, tokenController: tokenController!)
        service.strictSSL = strictSSL
        return service
    }
    
    private func initializeLogging()
    {
        self.loggingService = KZLogging(endPoint: self.applicationConfiguration.loggingV3!,
                                            name: nil,
                                 tokenController: tokenController)
        self.loggingService.strictSSL = self.strictSSL
        
        var eventsLoggerEndPoint = self.applicationConfiguration.url!
        
        if (!eventsLoggerEndPoint.hasSuffix("/")) {
            eventsLoggerEndPoint = eventsLoggerEndPoint + "/"
        }

        self.eventsLoggerService = KZLogging(endPoint: eventsLoggerEndPoint, name: nil, tokenController: tokenController)
        self.eventsLoggerService.strictSSL = self.strictSSL
    }
    
    private func initializeMail()
    {
        self.mailService = KZMail(endPoint: self.applicationConfiguration.email!, name: "", tokenController: tokenController!)
        self.mailService.strictSSL = self.strictSSL
    }
    
    private func initializePushNotifications()
    {
        self.notificationsService = KZNotification(endPoint: self.applicationConfiguration.notification!,
            name: self.applicationConfiguration.name!,
            tokenController: tokenController!)
        self.notificationsService.strictSSL = self.strictSSL
    }
    
    private func initializeAnalytics() {
        self.analytics = KZAnalytics(loggingService: self.eventsLoggerService)
    }
    
    func tagClick(buttonName:String) {
        self.analytics.tagClick(buttonName: buttonName)
    }
    
    
    func tagView(viewName:String) {
        self.analytics.tagView(viewName: viewName)
    }
    
    
    func tagEvent(customEventName:String, attributes:Dictionary<String, AnyObject>) {
        self.analytics.tagEvent(customEventName: customEventName, attributes: attributes)
    }
    
    func enableAnalytics() {
        self.analytics.enableAnalytics()
    }

}
