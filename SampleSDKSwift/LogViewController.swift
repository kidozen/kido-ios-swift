//
//  LogViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/26/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class LogViewController : UIViewController {
 
    var kzApplication : KZApplication?
    var logService : KZLogging?
    
    @IBOutlet weak var reponseTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        self.title = "Log SDK Demo"
    }
    
    @IBAction func queryPressed(sender: AnyObject) {
        logService = kzApplication?.loggingService
        logService?.all({ () -> () in
            
        }, success: { (response, responseObject) -> () in
            self.reponseTextView.text = "\(responseObject)"
            
        }, failure: { [weak self] (response, error) -> () in
            self!.showError(error)
        })
    }
    
    private func showError(error:NSError?)
    {
        self.activityIndicator.stopAnimating()
        UIAlertView(  title: "Error while querying",
            message: error?.localizedDescription,
            delegate:nil,
            cancelButtonTitle: "OK").show()
    }
    
}