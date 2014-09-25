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
        
        var jsonData : NSData = valueTextFieldSave.text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        let jsonDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: nil) as? Dictionary<String, String>
        
        if (jsonDictionary? != nil) {
            
            configService?.save(jsonDictionary, willStartCb: nil, success: { (response, responseObject) -> () in
                UIAlertView(title: "Saved!", message: "Config Saved!", delegate: nil, cancelButtonTitle: "Ok").show()
                }, failure: { (response, error) -> () in
                    
                    UIAlertView(title: "Error found", message: "Message", delegate: nil, cancelButtonTitle: "Ok").show()
                    
            })
        }
        else
        {
            UIAlertView(title: "Error", message: "Should be in json format", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    @IBAction func queryPressed(sender: UIButton) {
        configService = kzApplication?.configuration(nameTextFieldQuery.text)
        
        configService?.get(willStartCb: nil, success: { [weak self](response, responseObject) -> () in
            self!.responseTextField.text = "\(responseObject?)"
            
            }, failure: { (response, error) -> () in
                UIAlertView(title: "Error found", message: "error is \(error?)", delegate: nil, cancelButtonTitle: "Ok").show()
                
        })
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func removePressed(sender: UIButton) {
        configService = kzApplication?.configuration(nameTextFieldQuery.text)
        
        configService?.remove(nil, success: { [weak self](response, responseObject) -> () in
            self!.responseTextField.text = "\(responseObject?)"
            
            }, failure: { (response, error) -> () in
                UIAlertView(title: "Error found", message: "error is \(error)", delegate: nil, cancelButtonTitle: "Ok").show()
                
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