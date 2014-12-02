//
//  KZFileStorage.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 11/24/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

let PRAGMA_HEADER = "Pragma"
let CACHE_CONTROL_HEADER = "Cache-Control"
let NO_CACHE_VALUE_HEADER = "no-cache"

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
                        NSData in the response parameter
    :param: didFailCb   is the failure block
    */
    public func download(#filePath:String,
                       willStartCb:kzVoidCb?,
                       didFinishCb:kzDidFinishCb?,
                         didFailCb:kzDidFailCb?)
    {
        willStartCb?()
        var path = self.sanitize(filePath, isDirectory: false)

        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        networkManager.configureResponseSerializer(AFHTTPResponseSerializer())
        
        self.networkManager.addHeaders([PRAGMA_HEADER : NO_CACHE_VALUE_HEADER,
                                  CACHE_CONTROL_HEADER : NO_CACHE_VALUE_HEADER])
        
        
        self.addAuthorizationHeader()


        self.networkManager.GET(path: path,
                          parameters: nil,
                             success: didFinishCb,
                             failure: didFailCb)
    }

    /**
        This method will upload the data provided in the corresponding filePath.
    
        :param: data        It's the data representation of what you want to upload
        :param: filePath    This is the full filepath you want the data to be uploaded
        :param: willStartCb Callback that will get called just before executing the request.
        :param: didFinishCb Successfully finished the upload call callback.
        :param: didFailCb   Failure block.
    */
    public func uploadFile(data:NSData,
                       filePath:String,
                    willStartCb:kzVoidCb?,
                    didFinishCb:kzDidFinishCb?,
                      didFailCb:kzDidFailCb?,
                 bytesWrittenCb:kzWrittenCb?)
    {
        
        willStartCb?()
        var path = self.sanitize(filePath, isDirectory: false)
        
        let attachments = [path.onlyFilename()! : data]
        
        let params = ["x-file-name" : path.onlyFilename()!]
        
        self.networkManager.uploadFile(path: path,
                                       data: data,
                                  writtenCb: bytesWrittenCb,
                                    success: didFinishCb,
                                    failure: didFailCb)
        
    }

    /**
        This method will let you browse through what you have uploaded.
    
    :param: path        is the folder you wish to browse.
    :param: willStartCb callback that will get called when starting the operation.
    :param: didFinishCb finish callback.
    :param: didFailCb   failure callback
    */
    public func browse(#path:String, willStartCb:kzVoidCb?, didFinishCb:kzDidFinishCb?, didFailCb:kzDidFailCb?) {
        
        willStartCb?()
        
        let sanitizedPath = self.sanitize(path, isDirectory:true)
        
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        
        self.networkManager.addHeaders([PRAGMA_HEADER : NO_CACHE_VALUE_HEADER,
                                 CACHE_CONTROL_HEADER : NO_CACHE_VALUE_HEADER])
        
        self.addAuthorizationHeader()
        
        self.networkManager.GET(path: sanitizedPath,
                          parameters: nil,
                             success: didFinishCb,
                             failure: didFailCb)
    }

    /**
    This method will delete the file/directory that is located at the filePath provided.
    
    :param: path        This is the full path to the file/directory you want to download. If you wish
                        to delete a directory, filePath should end with '/'
    :param: willStartCb callback that will get called when starting the operation.
    :param: didFinishCb finish callback.
    :param: didFailCb   failure callback
    */
    public func delete(#path:String, willStartCb:kzVoidCb?, didFinishCb:kzDidFinishCb?, didFailCb:kzDidFailCb?) {
        willStartCb?()
        
        let sanitizedPath = self.sanitize(path, isDirectory:true)
        
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        
        self.networkManager.addHeaders([PRAGMA_HEADER : NO_CACHE_VALUE_HEADER,
                                 CACHE_CONTROL_HEADER : NO_CACHE_VALUE_HEADER])
        
        self.addAuthorizationHeader()
        
        self.networkManager.DELETE(path: sanitizedPath,
                             parameters: nil,
                                success: didFinishCb,
                                failure: didFailCb)
        
    }
    // This method will sanitize the filePath for this particular use case.
    // If it's a directory, end with a '/', otherwise not
    private func sanitize(filePath:String, isDirectory:Bool) -> String {
        if (filePath.isEmpty) {
            NSException.raise(NSInvalidArgumentException, format: "Filepath must not be empty", arguments:getVaList([]))
        }
        
        var charSet : NSMutableCharacterSet = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
        charSet.addCharactersInString("/")
        
        var path = filePath.stringByTrimmingCharactersInSet(charSet)

        if (isDirectory == true) {
            if (!filePath.hasSuffix("/")) {
                path = path + "/"
            }
        }
        
        return path
        

    }
}
