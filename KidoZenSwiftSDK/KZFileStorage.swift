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
        
        self.networkManager.addHeaders(["Pragma" : "no-cache",
                                 "Cache-Control" : "no-cache"])
        
        
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
