//
//  KZApplication.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*!
    This class encapsulates all services such as Logging, Mail, Notifications,
    DataSources, etc... as well as providing a convinient interface for the
    developer to interact with KidoZen.

    You must have and instance of this class in order to interact with KidoZen's services.
 */
public class KZApplication : KZObject {
    
    public var loggingService : KZLogging!
    public var mailService : KZMail!
    public var notificationService : KZNotification!
    
    public var didFinishAuthenticationCb : kzDidFinishCb?
    public var didFailAuthenticationCb : kzDidFailCb?
    
    internal var applicationAuthentication : KZApplicationAuthentication!
    
    private var applicationConfiguration = KZApplicationConfiguration()
    private var applicationServices : KZApplicationServices!
    private var crashReporter : KZCrashReporter?

    private var tenantMarketPlace : String
    private var applicationKey : String
    private var applicationName : String
    private var strictSSL : Bool
    
    
    /**
     *
     * You should initialize your KZApplication class with this initializer.
     *
     * @param tenantMarketPlace The url of the KidoZen marketplace. (Required)
     * @param applicationName The application name (Required)
     * @param applicationKey Is the application key that gives you access to logging services (Required)
     * without username/password authentication.
     * @param strictSSL Whether we want SSL to be bypassed or not,  only use in development (Required)
     *
     */
    public init(tenantMarketPlace:String,
                  applicationName:String,
                   applicationKey:String,
                        strictSSL:Bool)
    {

        self.applicationKey = applicationKey
        
        // Sanitize the tenantMarketPlace.
        var characterSet = NSMutableCharacterSet.whitespaceCharacterSet()
        characterSet.addCharactersInString("/")
        self.tenantMarketPlace = tenantMarketPlace.stringByTrimmingCharactersInSet(characterSet)
        
        self.applicationName = applicationName
        self.strictSSL = strictSSL
        super.init()

    }
    
    
    /**
     * This method will download the application configuration and setup the authentication and services
     * class. It basically sets everything app so that you can just call the authentication method.
     * However, if you don't call this method before the authentication one, we'll call it for you, as
     * it's required in the authentication flow.
     */
    public func initializeServices(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        let initializeServicesSuccessCb = success
        let initializeServicesFailureCb = failure
        
        willStartCb?()
        self.applicationConfiguration.setup( tenant: self.tenantMarketPlace,
                                    applicationName: applicationName,
                                          strictSSL: strictSSL,
                                            success:
            {
                [weak self] (response, responseObject) -> () in
                    self!.configureAuthentication()
                
                    self!.configureApplicationServices()
                
                    self!.applicationAuthentication.handleAuthentication(applicationKey: self!.applicationKey,
                                                                             willStartCb: nil,
                                                                                 success: initializeServicesSuccessCb,
                                                                                 failure: initializeServicesFailureCb)

        }, failure:initializeServicesFailureCb)
    }
}



// Authentication
extension KZApplication {
    
    public func authenticate(  #user : NSString,
                            provider : NSString,
                            password : NSString,
                             success : kzDidFinishCb?,
                             failure : kzDidFailCb?)
    {
        self.didFinishAuthenticationCb = success
        self.didFailAuthenticationCb = failure
        
        // If configuration has been downloaded, then call authentication, otherwise
        // call initServices and then authenticate.
        if ( self.isConfigured() ) {
            
            self.authenticate(user: user, provider: provider, password: password)
            
        } else {
            
            self.initializeServices(willStartCb: nil, success:
                {
                    [weak self](response, responseObject) in
                    self!.authenticate(user:user, provider: provider, password: password)
                }, failure: {
                    (response, error) in
                    
                    if let outerFailure = failure {
                        outerFailure(response: response, error: error)
                    }
            })
        }
    }
  
    public func doPassiveAuthentication(#success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.applicationAuthentication.doPassiveAuthentication(success, failure: failure)
    }
    
    private func isConfigured() -> Bool
    {
        return self.applicationAuthentication? != nil && self.applicationServices? != nil
    }
    
    private func authenticate(  #user : NSString,
                             provider : NSString,
                             password : NSString)
    {
        self.applicationAuthentication.authenticate(   user:user,
            provider:provider,
            password:password,
            success:self.didFinishAuthenticationCb,
            failure:self.didFailAuthenticationCb)
    }

    private func configureAuthentication()
    {
        self.applicationAuthentication = KZApplicationAuthentication(applicationConfiguration: self.applicationConfiguration,
            tenantMarketPlace: self.tenantMarketPlace,
            strictSSL: self.strictSSL)
        
    }
    
    public func isAuthenticated() -> Bool
    {
        return self.applicationAuthentication.authenticated == true
    }
    
}

/// Services, Datasource, Configuration, Queue, etc...
extension KZApplication {
    
    public func datasource(#name:String) -> KZDatasource
    {
        return self.applicationServices.datasource(name: name)
    }
    
    public func configuration(#name:String) -> KZConfiguration
    {
        return self.applicationServices.configuration(name: name)
    }
    
    public func queue(name:String) -> KZQueue
    {
        return self.applicationServices.queue(name:name)
    }

    public func storage(name:String) -> KZStorage
    {
        return self.applicationServices.storage(name: name)
    }
    
    public func SMSSender(number:String) -> KZSMSSender
    {
        return self.applicationServices.SMSSender(number:number)
    }

    public func LOBServiceWithName(name:String) -> KZService
    {
        return self.applicationServices.LOBServiceWithName(name:name)
    }
}

// Services - Logging
extension KZApplication {
    
    public func write(#object:Dictionary<String, AnyObject>?,
        message:String?,
        level:LogLevel,
        willStartCb:kzVoidCb?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        self.loggingService.write(object: object, message:message,
                                             level: level,
                                       willStartCb: willStartCb,
                                           success: success,
                                           failure: failure)
    }
    
    public func allLogMessages(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.loggingService.all(willStartCb, success: success, failure: failure)
    }
    
    public func clear(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.loggingService.clear(willStartCb, success: success, failure: failure)
    }
    
    private func configureApplicationServices()
    {
        self.applicationServices = KZApplicationServices(applicationConfiguration: self.applicationConfiguration,
                                                                  tokenController: self.applicationAuthentication.tokenController,
                                                                        strictSSL: self.strictSSL)
        
        self.loggingService = self.applicationServices.loggingService
        self.mailService = self.applicationServices.mailService
        self.notificationService = self.applicationServices.notificationsService
        // TODO: Data visualization
        // TODO: Analytics service.
    }
}


/// Mail service
/// Some handy methods to send emails without having to get the mailService property.
extension KZApplication {
    
    /**
    * This method will send an email to the corresponding receipient. No attachments sent.
    * @parameters is a required dictionary with the following keys:
    *              from, to, subject, bodyHtml, bodyText
    */
    public func sendMail(#parameters:Dictionary<String, String>, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?) {
        self.mailService.send(parameters: parameters, willStartCb: willStartCb, success: success, failure: failure)
    }
    
    /**
    *
    * This method will send an email to the corresponding receipient with the attachments that are provided
    * in the attachments parameter.
    *
    * @param parameters is a required dictionary with the following keys:
    *              from, to, subject, bodyHtml, bodyText
    * @param attachments is a dictionary where the key is the name of the attachment and the value is the NSData to be sent.
    */
    public func sendMail(#parameters:Dictionary<String, String>, attachments:Dictionary<String, AnyObject>?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?) {
        self.mailService.send(parameters: parameters, attachments: attachments, willStartCb: willStartCb, success: success, failure: failure)
    }
}

/// Crash reporting
extension KZApplication {

    // Will enable crash reporting and, in case there is a dump to be sent to the server, it'll do so and it'll call 
    // the corresponding callbacks.
    public func enableCrashReporter(#willStartCb:kzVoidCb?, didSendCrashReportCb:kzDidFinishCb?, didFailCrashReportCb:kzDidFailCb?)
    {
        if (self.crashReporter? == nil || self.crashReporter?.isInitialized == false) {
            if (NSGetUncaughtExceptionHandler() != nil) {
                println("Warning -- NSSetUncaughtExceptionHandler is not nil. Overriding will occur")
            }

            self.crashReporter = KZCrashReporter(urlString: self.applicationConfiguration.url!, tokenController: self.applicationAuthentication.tokenController, strictSSL: self.strictSSL)
                self.crashReporter?.enableCrashReporter(willStartCb, didSendCrashReportCb:didSendCrashReportCb
                                                            , didFailCrashReportCb:didFailCrashReportCb)
        }

    }


    // Will enable crash reporting and, in case a report has to be sent, it'll do so without any callbacks or anything.
    public func enableCrashReporter() {
        self.enableCrashReporter(nil, didSendCrashReportCb:nil, didFailCrashReportCb:nil)
    }
}
