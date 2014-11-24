//
//  KZFileStorage.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 11/24/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

/**
* This is the File Service, which will let you perform some operations such as
* uploading, deleting, getting files from the cloud.
*/
public class KZFileStorage : KZBaseService {
  
    /**
    This method will download the file that is located at the filePath provided.
    
    :param: filePath    This is the full path to the file you want to download.
    It should not end with a '/', as it's a file
    :param: willStartCb is a block that will get called upon starting to download the file.
    :param: didFinishCb is a success block that will get called. If the file is found, it'll be an 
                        NSData in the finish parameter.
    :param: didFailCb   is the failure block
    */
    public func download(#filePath:String,
                       willStartCb:kzVoidCb?,
                       didFinishCb:kzDidFinishCb?,
                         didFailCb:kzDidFailCb?)
    {
        willStartCb?()
        var path = self.sanitize(filePath, isDirectory: false)
        
        self.networkManager.addHeaders(["Pragma" : "no-cache",
                                 "Cache-Control" : "no-cache"])
        
        
        self.addAuthorizationHeader()

        // Datasources request and response will always be in json.
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        networkManager.configureResponseSerializer(AFHTTPResponseSerializer())

        self.networkManager.GET(path: filePath,
                          parameters: nil,
                             success: didFinishCb,
                             failure: didFailCb)
    }


    // This method will sanitize the filePath for this particular use case.
    // If it's a directory, it should start with a '/' and end with a '/'
    // Otherwise, it should start with '/' and NOT end with '/'
    private func sanitize(filePath:String, isDirectory:Bool) -> String {
        if (filePath.isEmpty) {
            NSException.raise(NSInvalidArgumentException, format: "Filepath must not be empty", arguments:getVaList([]))
        }
        
        
        var path = filePath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        
        if (!filePath.hasPrefix("/")) {
            path = "/" + filePath
        }
        
        if (isDirectory == true) {
            if (!filePath.hasSuffix("/")) {
                path = path + "/"
            }
        }
        
        return path
        

    }
}
