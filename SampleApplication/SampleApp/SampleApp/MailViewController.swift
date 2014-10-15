//
//  MailViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 9/8/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import UIKit
import KidoZen

class MailViewController : UIViewController {
 
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextfield: UITextField!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var subjectTextField: UITextField!
    
    var kzApplication : KZApplication?
    
    override func viewDidLoad() {
        self.title = "Email Sample SDK"
    }
    
    @IBAction func sendEmail(sender: AnyObject) {
        let to : String = toTextfield.text
        let from : String = fromTextField.text
        let subject : String = subjectTextField.text
        let messageText : String = message.text
        
        let mailDictionary = ["to" : to, "from" : from, "subject": subject, "bodyText" : messageText];
        
        activityIndicator.startAnimating()
        
        self.kzApplication?.sendMail(parameters: mailDictionary, willStartCb: nil,
            success: { [weak self](response, responseObject) -> () in
                self!.activityIndicator.stopAnimating()
                UIAlertView(title: "Email Sent", message: "The email has been sent", delegate: nil, cancelButtonTitle: "Ok").show()
            
            }, failure: { [weak self](response, error) -> () in
                self!.activityIndicator.stopAnimating()
                UIAlertView(title: "Email Fail", message: "An error occured while sending email", delegate: nil, cancelButtonTitle: "Ok").show()
            
        })
    }
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}