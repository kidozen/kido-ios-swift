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
class KZApplicationConfiguration : KZObject {
    private let kAppConfigPath = "/publicapi/apps"
    private let kApplicationNameKey = "name"
    
    var displayName : String?
    var customUrl : String?
    var domain : String?
    var name : String?
    var path : String?
    var port : Int?
    var published : Bool?
    var uploads : String?
    var tileIcon : String?
    var tileColor : String?
    var applicationDescription : String?
    var shortDescription : String?
    var categories : [AnyObject]?
    var tile : String?
    var url : String?
    var gitUrl : String?
    var ftp : String?
    var ws : String?
    var notification : String?
    var storage : String?
    var queue : String?
    var pubsub : String?
    var config: String?
    var logging: String?
    var loggingV3 : String?
    var email : String?
    var sms : String?
    var service: String?
    var datasource : String?
    var files : String?
    var img: String?
    var rating : String?
    var html5Url : String?
    var authConfig : KZAuthenticationConfig?
    
    private var networkManager : KZNetworkManager?
    
    func setup(#tenant: String?,
        applicationName: String?,
        strictSSL: Bool?,
        success:kzDidFinishCb?,
        failure:kzDidFailCb?)
    {
        
        let parameters = [kApplicationNameKey : applicationName!]
        networkManager = KZNetworkManager(baseURLString:tenant!, strictSSL: false, tokenController:nil)
        
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
    
    private func configure(dictionary:Dictionary<String, AnyObject>)
    {
        
        // TODO: There's gotta be a better way to dynamically 
        // assign this in swift.
        displayName = (dictionary["displayName"] as AnyObject?) as? String
        domain = (dictionary["domain"] as AnyObject?) as? String
        name = (dictionary["name"] as AnyObject?) as? String
        path = (dictionary["path"] as AnyObject?) as? String
        port = (dictionary["port"] as AnyObject?) as? Int
        published = (dictionary["published"] as AnyObject?) as? Bool
        uploads = (dictionary["uploads"] as AnyObject?) as? String
        tileIcon = (dictionary["tile-icon"] as AnyObject?) as? String
        tileColor = (dictionary["tile-color"] as AnyObject?) as? String
        applicationDescription = (dictionary["description"] as AnyObject?) as? String
        shortDescription = (dictionary["shortDescription"] as AnyObject?) as? String
        categories = (dictionary["categories"] as AnyObject?) as? [AnyObject]
        tile = (dictionary["tile"] as AnyObject?) as? String
        url = (dictionary["url"] as AnyObject?) as? String
        gitUrl = (dictionary["gitUrl"] as AnyObject?) as? String
        ftp = (dictionary["ftp"] as AnyObject?) as? String
        ws = (dictionary["ws"] as AnyObject?) as? String
        notification = (dictionary["notification"] as AnyObject?) as? String
        storage = (dictionary["storage"] as AnyObject?) as? String
        queue = (dictionary["queue"] as AnyObject?) as? String
        pubsub = (dictionary["pubsub"] as AnyObject?) as? String
        config = (dictionary["config"] as AnyObject?) as? String
        logging = (dictionary["logging"] as AnyObject?) as? String
        loggingV3 = (dictionary["logging-v3"] as AnyObject?) as? String
        email = (dictionary["email"] as AnyObject?) as? String
        sms = (dictionary["sms"] as AnyObject?) as? String
        service = (dictionary["service"] as AnyObject?) as? String
        datasource = (dictionary["datasource"] as AnyObject?) as? String
        files = (dictionary["files"] as AnyObject?) as? String
        img = (dictionary["img"] as AnyObject?) as? String
        rating = (dictionary["rating"] as AnyObject?) as? String
        html5Url = (dictionary["html5Url"] as AnyObject?) as? String
        
        
        let authConfigDictionary = (dictionary["authConfig"] as AnyObject?) as? Dictionary<String, AnyObject>
        authConfig = KZAuthenticationConfig(fromDictionary: authConfigDictionary!)
        
        
    }
    
    private func validConfig(forProvider provider:NSString?, error:NSError?) {
        // TODO: Have to check for parameters that are required. 
    }
    
}

