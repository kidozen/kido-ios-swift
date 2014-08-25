//
//  MenuViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/22/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController : UIViewController {
 
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var kzApplication : KZApplication?
    
    override func viewDidLoad() {
        self.title = "Kidozen Swift SDK Demo"
    }
    
    func enableView()
    {
        self.view.userInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func servicesPressed(sender: AnyObject)
    {
        
    }
    
    @IBAction func dataSourcesPressed(sender: AnyObject)
    {
        if (self.kzApplication!.applicationAuthentication.authenticated! == true) {
            var dsVC = DataSourceViewController(nibName: "DataSourceViewController", bundle: nil)
            self.navigationController.pushViewController(dsVC, animated: true)
        } else {
            UIAlertView(title: "First login", message: "First you have to authenticate.", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    @IBAction func activeLoginPressed(sender: AnyObject)
    {
        var loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginVC.kzApplication = kzApplication
        loginVC.didLogin = {
            UIAlertView(title: "Active login", message: "Successfully Authenticated!", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        
        self.navigationController.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func passiveLoginPressed(sender: AnyObject)
    {
        kzApplication?.doPassiveAuthentication(success: { (response, responseObject) in
            UIAlertView(title: "Passive Authentication", message: "Passive login success", delegate: nil, cancelButtonTitle: "Ok").show()
        }, failure: { (response, error) in
            UIAlertView(title: "Active login", message: "Authentication Fail", delegate: nil, cancelButtonTitle: "Ok").show()
        })
    }
}