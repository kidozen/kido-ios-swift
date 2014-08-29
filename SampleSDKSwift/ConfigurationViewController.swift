//
//  ConfigurationViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class ConfigurationViewController : UIViewController {
    
    @IBOutlet weak var nameTextFieldSave: UITextField!
    @IBOutlet weak var valueTextFieldSave: UITextField!
    @IBOutlet weak var nameTextFieldQuery: UITextField!
    @IBOutlet weak var responseTextField: UITextView!
    @IBOutlet weak var acitivtyIndicator: UIActivityIndicatorView!
    
    var kzApplication : KZApplication?
    var configService : KZConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Configuration SDK Demo"
    }
    
    @IBAction func save(sender: UIButton) {
        let configService = kzApplication?.configuration(nameTextFieldSave.text)
        
        configService?.save(valueTextFieldSave.text, willStartCb: nil, success: { (response, responseObject) -> () in
            
        }, failure: { (response, error) -> () in
            
            UIAlertView(title: "Error found", message: "Message", delegate: nil, cancelButtonTitle: "Ok").show()

        })
        
    }
    
    @IBAction func queryPressed(sender: UIButton) {
        configService = kzApplication?.configuration(nameTextFieldQuery.text)
        
        configService?.query(willStartCb: nil, success: { [weak self](response, responseObject) -> () in
            self!.responseTextField.text = "\(responseObject?)"

        }, failure: { (response, error) -> () in
            UIAlertView(title: "Error found", message: "Message", delegate: nil, cancelButtonTitle: "Ok").show()
            
        })
    }
    
    @IBAction func removePressed(sender: UIButton) {
        configService = kzApplication?.configuration(nameTextFieldQuery.text)
        
        configService?.remove(nil, success: { [weak self](response, responseObject) -> () in
            self!.responseTextField.text = "\(responseObject?)"
            
            }, failure: { (response, error) -> () in
                UIAlertView(title: "Error found", message: "Message", delegate: nil, cancelButtonTitle: "Ok").show()
                
        })
        
    }
    
    @IBAction func queryAllPressed(sender: AnyObject) {
        configService = kzApplication?.configuration(nameTextFieldQuery.text)
        configService?.all(nil, success: { [weak self] (response, responseObject) in
            self!.responseTextField.text = "\(responseObject?)"
        }, failure: { (response, error) -> () in
            
            UIAlertView(title: "Error found", message: "Message", delegate: nil, cancelButtonTitle: "Ok").show()
        })

    }
    
}