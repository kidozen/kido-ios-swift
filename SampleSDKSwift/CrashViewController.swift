//
//  CrashViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/28/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class CrashViewController : UIViewController {
    
    var kzApplication : KZApplication?
    
    @IBOutlet weak var enableCrashReporterButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func crashButtonPressed(sender: AnyObject) {
        self.enableCrash()
        let array = []
        println("\(array[1])")
    }
    
    @IBAction func enableCrashReporterPressed(sender: AnyObject) {
        self.enableCrash()
    }
    
    private func enableCrash() {
        self.enableCrashReporterButton.enabled = false
        kzApplication?.enableCrashReporter()
        
    }
    
}
