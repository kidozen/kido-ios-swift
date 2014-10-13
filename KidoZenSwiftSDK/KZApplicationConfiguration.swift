//
//  KZApplicationConfiguration.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

/*!
    This class models the configuration that comes in the json at the following URL
    https://TENANT_URL/publicapi/apps?name=APPNAME
*/
public class KZApplicationConfiguration : KZObject {
    private let kAppConfigPath = "/publicapi/apps"
    private let kApplicationNameKey = "name"
    
    public var displayName : String?
    public var customUrl : String?
    public var domain : String?
    public var name : String?
    public var path : String?
    public var port : Int?
    public var published : Bool?
    public var uploads : String?
    public var tileIcon : String?
    public var tileColor : String?
    public var applicationDescription : String?
    public var shortDescription : String?
    public var categories : [AnyObject]?
    public var tile : String?
    public var url : String?
    public var gitUrl : String?
    public var ftp : String?
    public var ws : String?
    public var notification : String?
    public var storage : String?
    public var queue : String?
    public var pubsub : String?
    public var config: String?
    public var logging: String?
    public var loggingV3 : String?
    public var email : String?
    public var sms : String?
    public var service: String?
    public var datasource : String?
    public var files : String?
    public var img: String?
    public var rating : String?
    public var html5Url : String?
    public var authConfig : KZAuthenticationConfig?
    
    private var networkManager : KZNetworkManager?
    
    internal func setup(#tenant: String,
        applicationName: String,
        strictSSL: Bool,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        
        let parameters = [kApplicationNameKey : applicationName]
        networkManager = KZNetworkManager(baseURLString:tenant, strictSSL: strictSSL, tokenController:nil)
        
        networkManager!.GET(path:kAppConfigPath,
                        parameters:parameters,
                            success:
            {
                (operation, responseObject) in
                
                    // Handle case where there is no configuration.
                    // Handle configError

                    let array = responseObject as? Array<AnyObject>
                    let responseDictionary = array![0] as? Dictionary<String, AnyObject>
                
                    self.configure(responseDictionary!)
                    success?(response: operation, responseObject: responseObject)
            },
            failure: {
                // Should call callback with error.
                // Handle case where there is no configuration.
                // Handle configError

                (response,error) in
                if let outerFailure = failure {
                    outerFailure(response: response, error: error)
                }
            });
            
    }
    
    private func configure(responseDictionary:Dictionary<String, AnyObject>)
    {
        
        // TODO: There's gotta be a better way to dynamically 
        // assign this in swift.
        displayName = (responseDictionary["displayName"] as AnyObject?) as? String
        domain = (responseDictionary["domain"] as AnyObject?) as? String
        name = (responseDictionary["name"] as AnyObject?) as? String
        path = (responseDictionary["path"] as AnyObject?) as? String
        port = (responseDictionary["port"] as AnyObject?) as? Int
        published = (responseDictionary["published"] as AnyObject?) as? Bool
        uploads = (responseDictionary["uploads"] as AnyObject?) as? String
        tileIcon = (responseDictionary["tile-icon"] as AnyObject?) as? String
        tileColor = (responseDictionary["tile-color"] as AnyObject?) as? String
        applicationDescription = (responseDictionary["description"] as AnyObject?) as? String
        shortDescription = (responseDictionary["shortDescription"] as AnyObject?) as? String
        categories = (responseDictionary["categories"] as AnyObject?) as? [AnyObject]
        tile = (responseDictionary["tile"] as AnyObject?) as? String
        url = (responseDictionary["url"] as AnyObject?) as? String
        gitUrl = (responseDictionary["gitUrl"] as AnyObject?) as? String
        ftp = (responseDictionary["ftp"] as AnyObject?) as? String
        ws = (responseDictionary["ws"] as AnyObject?) as? String
        notification = (responseDictionary["notification"] as AnyObject?) as? String
        storage = (responseDictionary["storage"] as AnyObject?) as? String
        queue = (responseDictionary["queue"] as AnyObject?) as? String
        pubsub = (responseDictionary["pubsub"] as AnyObject?) as? String
        config = (responseDictionary["config"] as AnyObject?) as? String
        logging = (responseDictionary["logging"] as AnyObject?) as? String
        loggingV3 = (responseDictionary["logging-v3"] as AnyObject?) as? String
        email = (responseDictionary["email"] as AnyObject?) as? String
        sms = (responseDictionary["sms"] as AnyObject?) as? String
        service = (responseDictionary["service"] as AnyObject?) as? String
        datasource = (responseDictionary["datasource"] as AnyObject?) as? String
        files = (responseDictionary["files"] as AnyObject?) as? String
        img = (responseDictionary["img"] as AnyObject?) as? String
        rating = (responseDictionary["rating"] as AnyObject?) as? String
        html5Url = (responseDictionary["html5Url"] as AnyObject?) as? String
        
        
        let authConfigDictionary = (responseDictionary["authConfig"] as AnyObject?) as? Dictionary<String, AnyObject>
        authConfig = KZAuthenticationConfig(fromDictionary: authConfigDictionary!)
        
        
    }
    
    private func validConfig(forProvider provider:NSString?, error:NSError?) {
        // TODO: Have to check for parameters that are required. 
    }
    
}

