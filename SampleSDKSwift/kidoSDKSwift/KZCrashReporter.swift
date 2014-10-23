//
//  KZCrashReporter.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/21/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation


class KZCrashReporter
{
    private var success:kzDidFinishCb?
    private var failure:kzDidFailCb?
    
    private var version : String?
    private var build : String?
    
    private let tokenController : KZTokenController!
    private let networkManager : KZNetworkManager!
    private var internalCrashReporterInfo : Dictionary<String, AnyObject>
    
    private let reporterServiceUrl : String!
    
    private weak var crashReporter : PLCrashReporter?
    private var stringCrashReport : String!
    
    var isInitialized : Bool
    
    init(urlString:String!, tokenController:KZTokenController!, strictSSL:Bool!)
    {
        self.isInitialized = false
        self.internalCrashReporterInfo = Dictionary<String, AnyObject>()
        self.tokenController = tokenController
        self.reporterServiceUrl = self.sanitize(urlString) + "/api/v3/logging/crash/ios/dump"
        self.networkManager = KZNetworkManager(baseURLString: reporterServiceUrl,
                                                   strictSSL: strictSSL,
                                             tokenController: tokenController)
        
    }
    
    func enableCrashReporter(willStartCb:kzVoidCb?, didSendCrashReportCb:kzDidFinishCb?, didFailCrashReportCb:kzDidFailCb?)
    {
        willStartCb?()
        self.success = didSendCrashReportCb
        self.failure = didFailCrashReportCb
        
        self.crashReporter = PLCrashReporter.sharedReporter()
        
        if (self.crashReporter?.hasPendingCrashReport() == true) {
            self.manageCrashReport()
        }
        
        var error : NSError?
        
        if (self.crashReporter?.enableCrashReporterAndReturnError(&error) == false) {
            failure?(response: nil, error: error)
            NSLog("Could not enable crash reporter. Error is \(error)")
        }
        
        self.isInitialized = true
        
    }
    
    private func stringifiedCrashReport(theData:NSData!, inout error:NSError?) -> String?
    {
        
        var report = PLCrashReport(data: theData, error: &error)
        
        if (error? != nil) {
            failure?(response: nil, error: error)
            return nil;
            
        } else {
            internalCrashReporterInfo["CrashedOn"] = "\(report.systemInfo.timestamp)"
            
            let signalString = "\(report.signalInfo.name) (code \(report.signalInfo.code), address=0x\(report.signalInfo.address))"
            internalCrashReporterInfo["CrashedWithSignal"] = signalString
            
            return PLCrashReportTextFormatter.stringValueForCrashReport(report, withTextFormat: PLCrashReportTextFormatiOS)
            
        }
    }
    
    private func manageCrashReport()
    {
        var error : NSError?
        
        if let crashData = self.crashReporter?.loadPendingCrashReportDataAndReturnError(&error)
        {
            
            self.stringCrashReport = self.stringifiedCrashReport(crashData, error:&error)
            
            if (error? == nil) {
                internalCrashReporterInfo["ReporterDataAsString"] = self.stringCrashReport

                if (self.reporterServiceUrl? != nil) {
                    self.postReport()
                } else {
                    self.saveReport()
                }
                
            } else {
                failure?(response: nil, error: error)
            }
            
        } else {
            failure?(response: nil, error: error)
        }
    }

    private func saveReport()
    {
        let outputPath = self.pathForFilename("KidozenCrashReport.crash")
        var error : NSError?
        
        if (!self.stringCrashReport.writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)) {
            println("Failed to write crash report")
            failure?(response: nil, error: error)
        } else {
            internalCrashReporterInfo["CrashOutputPath"] = "Saved crash report to: \(outputPath)"
        }
        self.crashReporter?.purgePendingCrashReport()
    }
    
    private func postReport()
    {
        self.version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        self.build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as NSString) as? String

        var breadcrumbs = String(contentsOfFile: self.breadcrumbFilename(), encoding: NSUTF8StringEncoding, error: nil)
        
        if (breadcrumbs? == nil) {
            breadcrumbs = ""
        }
        
        let breadcrumbsArray = breadcrumbs?.componentsSeparatedByString("\n")
        
        let parameters : Dictionary<String, AnyObject> = ["REPORT" : self.stringCrashReport,
            "VERSION" : self.version!,
            "BUILD" : self.build!,
            "BREADCRUMBS" : breadcrumbsArray!]
        
        
        self.networkManager.strictSSL = false
        self.networkManager.configureRequestSerializer(AFJSONRequestSerializer() as AFHTTPRequestSerializer)
        self.networkManager.configureResponseSerializer(AFHTTPResponseSerializer() as AFHTTPResponseSerializer)
        self.networkManager.addAuthorizationHeader(tokenController.kzToken)
        
        // We have to override the Content-Type to only be application/json, dropping the charset, because
        // the server just won't allow anything else.
        self.networkManager.addHeaders(["Accept": "application/json", "Content-Type": "application/json"])
        
        self.networkManager.POST(path: "",
                           parameters: parameters,
                              success:
            {
                [weak self] (response, responseObject) in
            
                    var error : NSError?
            
                    if ((self!.crashReporter?.purgePendingCrashReportAndReturnError(&error)) == false) {
                        println("Something happened while removing dump. Error is \(error)")
                    }
                
                    self!.removeBreadcrumbsFile()
                    self!.internalCrashReporterInfo["response"] = response!.urlRequestOperation
                    self!.internalCrashReporterInfo["responseObject"] = responseObject
                    self!.success!(response:response, responseObject:responseObject)

            }, failure: { [weak self](response, error) in
                self!.failure!(response: response, error: error)
            })

    }
    

    private func removeBreadcrumbsFile()
    {
        let fm = NSFileManager.defaultManager()
        let breadcrumbFilePath = self.breadcrumbFilename()
        
        if (fm.fileExistsAtPath(breadcrumbFilePath)) {
            var error : NSError?
            fm.removeItemAtPath(breadcrumbFilePath, error: &error)
            
            if (error? != nil) {
                failure?(response: nil, error: error)
                println("Could note remove \(breadcrumbFilePath). Error is \(error)")
            }
        }
    }
    
    private func breadcrumbFilename() -> String!
    {
        return self.pathForFilename("CrashUserLogs.log")
    }
    
    private func pathForFilename(filename:String!) -> String!
    {
        let pathArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, false)
        let documentsDirectory : String = pathArray[0] as String
        return documentsDirectory.stringByAppendingPathComponent(filename)
    }
    
    
    private func sanitize(urlString:String!) -> String!
    {
        var characterSet = NSMutableCharacterSet.whitespaceCharacterSet()
        characterSet.addCharactersInString("/")
        
        return urlString.stringByTrimmingCharactersInSet(characterSet)
    }
    
    


}