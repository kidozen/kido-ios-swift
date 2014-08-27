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
    @IBOutlet weak var keyTextfield: UITextField!
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var titleTextfield: UITextField!
    
    override func viewDidLoad() {
        self.title = "Log SDK Demo"
    }
    
    @IBAction func clearPressed(sender: AnyObject) {
        kzApplication?.clear({ () -> () in
            
        }, success: { [weak self](response, responseObject) -> () in
            
            UIAlertView(  title: "Log Cleared",
                message: "Log Cleared",
                delegate:nil,
                cancelButtonTitle: "OK").show()
            self!.reponseTextView.text = "\(responseObject?)"

        }, failure: { [weak self](response, error) -> () in
            self!.showError(error)
        })
    }
    
    @IBAction func writePressed(sender: AnyObject) {
        let title = titleTextfield.text
        let key = keyTextfield.text
        let value = valueTextfield.text
        
        let dictionary = [key:value]
        
        kzApplication?.write(dictionary, message: title, level: LogLevel.LogLevelError, willStartCb: { () -> () in
            
        }, success: {[weak self] (response, responseObject) -> () in
            self!.reponseTextView.text = "\(responseObject?)"

        }, failure: { [weak self](response, error) -> () in
            self!.showError(error)
        })
        
    }
    
    @IBAction func queryPressed(sender: AnyObject) {
        logService = kzApplication?.loggingService
        logService?.all({ () -> () in
            
        }, success: { [weak self](response, responseObject) -> () in
            self!.reponseTextView.text = "\(responseObject)"
            
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