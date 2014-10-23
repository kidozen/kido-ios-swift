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

    private var applicationConfiguration : KZApplicationConfiguration?
    private weak var tokenController : KZTokenController!
    private var strictSSL : Bool?
    
    
    var loggingService : KZLogging!
    var notificationsService : KZNotification!
    var mailService : KZMail!
    
    init( applicationConfiguration:KZApplicationConfiguration?,
                   tokenController:KZTokenController?,
                         strictSSL:Bool?)
    {
        self.applicationConfiguration = applicationConfiguration
        self.tokenController = tokenController
        self.strictSSL = strictSSL
        
        self.initializeLogging()
        self.initializeMail()
        self.initializePushNotifications()
        
    }
    
    func datasource(name:String?) -> KZDatasource
    {
        var endPoint = applicationConfiguration?.datasource?.stringByAppendingString("/")
        var datasource = KZDatasource(endPoint: endPoint, name: name, tokenController:tokenController)
        datasource.strictSSL = strictSSL
        return datasource
    }
    
    func configuration(name:String?) -> KZConfiguration
    {
        var endPoint = applicationConfiguration?.config
        var configuration = KZConfiguration(endPoint: endPoint, name: name, tokenController: tokenController)
        configuration.strictSSL = strictSSL
        return configuration
    }
    
    func queue(name:String?) -> KZQueue
    {
        var endPoint = applicationConfiguration?.queue
        var queue = KZQueue(endPoint: endPoint, name: name, tokenController: tokenController)
        queue.strictSSL = strictSSL
        return queue
    }
    
    func storage(name:String?) -> KZStorage
    {
        var endPoint = applicationConfiguration?.storage
        var storage = KZStorage(endPoint: endPoint, name: name, tokenController: tokenController)
        storage.strictSSL = strictSSL
        return storage
    }
    
    func SMSSender(number:String?) -> KZSMSSender
    {
        var endPoint = applicationConfiguration?.sms
        var sender = KZSMSSender(endPoint: endPoint, name: number, tokenController: tokenController)
        sender.strictSSL = strictSSL
        return sender
    }
    
    func LOBServiceWithName(name:String?) -> KZService
    {
        var endPoint = "\(self.applicationConfiguration!.url!)api/services/\(name!)/"
            
        var service = KZService(endPoint: endPoint, name: name, tokenController: tokenController)
        service.strictSSL = strictSSL
        return service
    }
    
    private func initializeLogging()
    {
        self.loggingService = KZLogging(endPoint: self.applicationConfiguration?.loggingV3,
                                            name: nil,
                                 tokenController: tokenController)
        self.loggingService.strictSSL = self.strictSSL
    }
    
    private func initializeMail()
    {
        self.mailService = KZMail(endPoint: self.applicationConfiguration?.email, name: nil, tokenController: tokenController)
        self.mailService.strictSSL = self.strictSSL
    }
    
    private func initializePushNotifications()
    {
        self.notificationsService = KZNotification(endPoint: self.applicationConfiguration?.notification,
            name: self.applicationConfiguration?.name,
            tokenController: tokenController)
        self.notificationsService.strictSSL = self.strictSSL
    }
}