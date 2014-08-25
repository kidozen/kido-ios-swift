//
//  LoginViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/31/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var marketPlace: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var kzApplication : KZApplication?
    var tenantName = kTenant
    var appName = kApplicationName
    
    var didLogin : kzVoidCb?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        marketPlace.text = tenantName + " - " + appName
        self.title = "Active Login"
    }
    
    @IBAction func loginPressed(sender: AnyObject)
    {
        activityIndicator.startAnimating()
        kzApplication!.authenticate(username.text,
                                    provider: "Kidozen",
                                    password: password.text,
                                    success :
            {
                [weak self](response, responseObject) -> () in
                    self!.activityIndicator.stopAnimating()
                    self!.didLogin!()
            },
            failure:
            {
                [weak self](response, error) -> () in
                    self!.activityIndicator.stopAnimating()
                    UIAlertView(  title: "Error while authenticating",
                                message: error?.localizedDescription,
                               delegate:nil,
                      cancelButtonTitle: "OK").show()
            })
    }
}