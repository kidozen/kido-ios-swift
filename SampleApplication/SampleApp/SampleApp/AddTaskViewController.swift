//
//  AddTaskViewController.swift
//  SampleApp
//
//  Created by Nicolas Miyasato on 12/4/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import UIKit

class AddTaskViewController : UIViewController  {
    
    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
    }
    
    func cancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
}