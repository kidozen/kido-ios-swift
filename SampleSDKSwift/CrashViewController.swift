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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func crashButtonPressed(sender: AnyObject) {
        
        kzApplication?.enableCrashReporter(nil, didSendCrashReportCb:{
            
            [weak self](response, responseObject) in
            self!.enableView()
            let array = []
            println("\(array[1])")
            
            }, didFailCrashReportCb:{[weak self](response, error) in
                self!.enableView()
            }
        )
        
    }
    
    @IBAction func enableCrashReporterPressed(sender: AnyObject) {
        self.disableView()
        kzApplication?.enableCrashReporter(nil, didSendCrashReportCb:{
            [weak self](response, responseObject) in
            self!.enableView()
            }, didFailCrashReportCb:{[weak self](response, error) in
                self!.enableView()
            }
        )
    }
    
    private func enableView() {
        self.activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
    }
    
    private func disableView() {
        self.activityIndicator.startAnimating()
        self.view.userInteractionEnabled = false
    }
}
