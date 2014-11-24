//
//  KZLocationManager.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 11/21/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation
import CoreLocation


class KZLocationManager : NSObject, CLLocationManagerDelegate {
    private var locationManager : CLLocationManager!
    var didUpdateLocationCb : kzDidFinishUpdateLocationCb?
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 500
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

    }

    func enableLocationManager() {
        if (CLLocationManager.locationServicesEnabled() == false ||
            CLLocationManager.authorizationStatus() == .NotDetermined ||
            CLLocationManager.authorizationStatus() == .Denied ||
            CLLocationManager.authorizationStatus() == .Restricted) {
                if (self.locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
                    self.locationManager.requestWhenInUseAuthorization()
                } else {
                    UIAlertView(    title: "Enable Location Services",
                                  message: "Please enable Location Services for this application. Settings > Private > Location",
                                 delegate: nil,
                        cancelButtonTitle: "OK").show()
                }
                
                self.locationManager.startUpdatingLocation()
            }
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let currentLocation = locations[0] as CLLocation
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(currentLocation,
                                completionHandler: { [weak self] (placeMarksArray, error) in
                                    if let hasError = error {
                                        println("Geocode failed with error \(error)")
                                    } else {
                                        let placeMark = placeMarksArray[0] as CLPlacemark
                                        if (self!.didUpdateLocationCb != nil) {
                                            self!.didUpdateLocationCb!(placemark: placeMark)
                                        }
                                    }
        })
        
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if ( (CLLocationManager.locationServicesEnabled() == true ||
            CLLocationManager.authorizationStatus() == .Authorized ||
            CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) )
        {
            self.locationManager.startUpdatingLocation();
        }
    }

    

}