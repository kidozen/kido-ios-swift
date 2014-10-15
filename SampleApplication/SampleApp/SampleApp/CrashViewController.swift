//
//  CrashViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/28/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import UIKit
import KidoZen

class CrashViewController : UIViewController {
    
    var kzApplication : KZApplication?
    
    @IBOutlet weak var enableCrashReporterButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Crash SDK Demo"
    }
    
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
        
        kzApplication?.enableCrashReporter(nil, didSendCrashReportCb: { [weak self](response, responseObject) -> () in
            self!.logView.text = "\(responseObject)"
            
        }, didFailCrashReportCb: { [weak self] (response, error) -> () in
            self!.logView.text = "\(error)"
            
        })
        
    }
    
}
