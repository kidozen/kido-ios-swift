//
//  KZStorage.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/7/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

let kStorageErrorDomain = "KZStorageErrorDomain";
let ENULLMETADATA = 2

class KZStorage : KZBaseService
{
    override init(endPoint: String!, name: String?, tokenController: KZTokenController!)
    {
        super.init(endPoint: endPoint, name: name, tokenController: tokenController)
        self.configureNetworkManager()
    }

    
    func create(object : AnyObject?, options:Dictionary<String, String>?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()

        var path = self.name!
        if let queryString = options?.asQueryString() {
           path += "?" + queryString
        }
        
        self.networkManager.POST(path:path, parameters: object, success: success, failure: failure)
        
    }

    func createPrivate(object : AnyObject?, options:Dictionary<String, String>?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.create(object, options: ["isPrivate":"true"], willStartCb: willStartCb, success: success, failure: failure)
    }
    
    func update(usingId objectId:String, object:AnyObject?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        if let dictionaryObject = object as? Dictionary<String, AnyObject> {
            
            if (contains(dictionaryObject.keys, "_metadata") == false) {
                if let outerFailure = failure {
                    let error = NSError(domain: kStorageErrorDomain, code: 2, userInfo: [NSLocalizedDescriptionKey:"You must include the \"_metadata\" information" ])
                    outerFailure(response: nil, error: error)
                    return
                }
            }
        }
        
        let dictionaryObject = object as Dictionary<String, Dictionary<String, AnyObject>>
        let updatedMetadata = self.updateMetadataDates(dictionaryObject)
        
        self.networkManager.PUT(path: self.name! + "/" + objectId,
                            parameters: updatedMetadata,
                               success: success,
                               failure: failure)
    }

    func get(usingId objectId:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        self.networkManager.GET(path: self.name! + "/" + objectId,
                            parameters: nil,
                               success: success,
                               failure: failure)
    }

    
    func delete(usingId objectId:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        self.networkManager.DELETE(path: self.name! + "/" + objectId,
                               parameters: nil,
                                  success: success,
                                  failure: failure)
    }

    func drop(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        self.networkManager.DELETE(path:self.name,
                               parameters: nil,
                                  success: success,
                                  failure: failure)
    }

    func all(willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.query(nil, options: nil, fields:nil, willStartCb: willStartCb, success: success, failure: failure)
    }
    
    func query(queryString:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.query(queryString, options: nil, fields:nil, willStartCb: willStartCb, success: success, failure: failure)
    }

    func query(queryString:String, options:String, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.query(queryString, options: options, fields:nil, willStartCb: willStartCb, success: success, failure: failure)
    }

    
    func query(queryString:String?, options:String?, fields:String?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        networkManager.strictSSL = self.strictSSL!
        willStartCb?()
        
        let path = self.path(queryString, options: options, fields: fields)
        
        self.networkManager.GET(path:path,
                            parameters: nil,
                               success: success,
                               failure: failure)
    }
    
    private func updateMetadataDates(object: Dictionary<String, Dictionary<String, AnyObject>>) -> Dictionary<String, Dictionary<String, AnyObject>> {
        let metadataDictionary = object["_metadata"]! as Dictionary<String, AnyObject>
        
        let createdOn = metadataDictionary["createdOn"]! as? NSDate
        let updatedOn = metadataDictionary["updatedOn"]! as? NSDate
        
        // Copying dictionary
        var updatedMetadataDictionary = metadataDictionary
        
        var fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.mmm'Z'"
        
        if (createdOn? != nil)
        {
            let newDate = fmt.stringFromDate(createdOn!)
            updatedMetadataDictionary["createdOn"] = newDate
        }
        
        if (updatedOn? != nil) {
            let newDate = fmt.stringFromDate(updatedOn!)
            updatedMetadataDictionary["updatedOn"] = newDate
        }
        
        // copying dictinary
        var updatedObject = object
        
        updatedObject["_metadata"] = updatedMetadataDictionary
        
        return updatedObject
    }
    
    private func path(queryString:String?, options:String?, fields:String?) -> String?
    {
        var path = self.name!
        
        if (queryString? != nil) {
            path += "?query=" + queryString!
        }
        
        if (options? != nil) {
            path += "&options=" + options!
        }
        
        if (fields? != nil) {
            path += "&fields=" + fields!
        }
        
        return path
    }
    
    
    override func configureNetworkManager()
    {
        networkManager.configureRequestSerializer(AFJSONRequestSerializer() as AFHTTPRequestSerializer)
        networkManager.configureResponseSerializer(AFJSONResponseSerializer() as AFHTTPResponseSerializer)
        
        self.addAuthorizationHeader()
    }

}