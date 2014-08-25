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
 
    weak var kzApplication : KZApplication?
    
    override func viewDidLoad() {
        self.title = "Kidozen Swift SDK Demo"
    }
    
    @IBAction func servicesPressed(sender: AnyObject)
    {
        
    }
    
    @IBAction func dataSourcesPressed(sender: AnyObject)
    {
        
    }
    
    @IBAction func activeLoginPressed(sender: AnyObject)
    {
        var loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginVC.kzApplication = kzApplication
        loginVC.didLogin = {
            UIAlertView(title: "Did Login!", message: "Successfully logged in", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        
        self.navigationController.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func passiveLoginPressed(sender: AnyObject)
    {
        
    }
}