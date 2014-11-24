//
//  KZDeviceInfo.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 11/20/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation
import CoreTelephony
import CoreLocation

private let _singletonInstance = KZDeviceInfo()

/**
*   Provides device information that will be sent along the user-session event.
*/
class KZDeviceInfo {
    let kUniqueIdentificationFilename = "kUniqueIdentificationFilename"
    
    /// Your application version, which is in the app.info file.
    var appVersion : String!
    
    /// // e.g. @"iPhone", @"iPod touch"
    var deviceModel : String!
    
    /// e.g. @"4.0"
    var systemVersion : String!
    
    var isoCountryCode : String!
    
    private var reachability : Reachability!
    
    private var networkInfo : CTTelephonyNetworkInfo
    
    private var carrier : CTCarrier!
    
    var locationManager : KZLocationManager
    
    init() {
        self.networkInfo = CTTelephonyNetworkInfo()
        self.reachability = Reachability.reachabilityForInternetConnection()
        self.carrier = self.networkInfo.subscriberCellularProvider
        self.locationManager = KZLocationManager()
        
        self.appVersion = self.configureAppVersion()
        
        self.configureDeviceInfo()
    }
    
    class var sharedInstance : KZDeviceInfo {
        return _singletonInstance
    }
    
    private func configureDeviceInfo() {
        let currentDevice = UIDevice.currentDevice()
        self.deviceModel = currentDevice.model
        self.systemVersion = currentDevice.systemVersion
        
        self.isoCountryCode = "Unknown"
        
        self.locationManager.didUpdateLocationCb = { [weak self] (placeMark) in
            self!.isoCountryCode = placeMark.ISOcountryCode
        }
    }
    
    private func configureAppVersion() -> String {
        var version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as String
        if (version == "") {
            version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as String
        }
        
        return version
        
    }
    
    
    ///The name of the subscriber's cellular service provider.
    func carrierName() -> String {
        return self.carrier!.carrierName != nil ? self.carrier!.carrierName : "Unknown";
    }
    
    func getUniqueIdentification() -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var uniqueID : String? = userDefaults.valueForKey(kUniqueIdentificationFilename) as? String
        if  uniqueID != nil {
            return uniqueID!
        } else {
            uniqueID = NSUUID().UUIDString
            userDefaults.setValue(uniqueID, forKey:kUniqueIdentificationFilename)
            userDefaults.synchronize()
        }
        
        return uniqueID!
        
    }
    
    /**
    *  Will enable geolocation to know where the user is using the application.
    */
    func enableGeoLocation() {
        // TODO: Geolocation
    }
    
    func properties() -> Dictionary<String, AnyObject> {
        return ["carrierName": self.carrierName(),
                "networkAccess" : self.currentRadioAccessTechnology(),
                "isoCountryCode" : "ar",
                "deviceModel" : self.deviceModel,
                "systemVersion" : self.systemVersion,
                "uniqueID" : self.getUniqueIdentification()]
    }
    
    func currentRadioAccessTechnology() -> String {
        if (self.reachability.isReachableViaWiFi()) {
            return "WiFi"
        } else {
            return self.networkInfo.currentRadioAccessTechnology != nil ?
            self.networkInfo.currentRadioAccessTechnology : "Unknown"
        }
    }

    
}