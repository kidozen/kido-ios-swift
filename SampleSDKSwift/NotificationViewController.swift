//
//  NotificationViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class NotificationViewController : UIViewController {
    
    @IBOutlet weak var subscribeTextField: UITextField!
    @IBOutlet weak var unsubscribeTextfield: UITextField!
    @IBOutlet weak var channelField: UITextField!
    @IBOutlet weak var textMessageField: UITextField!
    
    var kzApplication : KZApplication!
    var deviceToken : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
    }
    
    @IBAction func subscribePressed(sender: AnyObject) {
        kzApplication.notificationService.subscribe(deviceWithToken: self.deviceToken, channel: self.subscribeTextField.text, willStartCb: nil, success: { [weak self](response, responseObject) -> () in
            self!.show("Subscribed!", message: "Subscribed to \(self!.subscribeTextField.text)")
            
        }) { [weak self] (response, error) -> () in
            self!.show("Error!", message: "Error found. \(error)")
        }
    }
    
    @IBAction func unsubscribePressed(sender: AnyObject) {
        kzApplication.notificationService.unsubscribe(deviceWithToken: self.deviceToken, channel: self.unsubscribeTextfield.text, willStartCb: nil, success: { [weak self](response, responseObject) -> () in
            self!.show("Unsubscribed!", message: "Unsubscribed to \(self!.unsubscribeTextfield.text)")
            
            }) { [weak self] (response, error) -> () in
                self!.show("Error!", message: "Error found. \(error)")
        }
        
    }
    
    @IBAction func pushPressed(sender: AnyObject) {
        var parameters = Dictionary<String, AnyObject>()
        parameters["text"] = self.textMessageField.text
        parameters["title"] = "iOS Title"
        parameters["type"] = "raw"
        
        kzApplication.notificationService.push(parameters, channel: self.channelField.text, willStartCb: nil, success: { [weak self] (response, responseObject) in

            self!.show("Push Action Send!", message:"Sent push action to server")
            
            }, failure: { [weak self] (response, error) in
                let errorDescription = error?.localizedDescription
                self!.show("Error found!", message:errorDescription!)
                
        })
    }
    
    @IBAction func listPressed(sender: AnyObject) {
        kzApplication.notificationService.getSubscriptions(nil, success: { [weak self] (response, responseObject) in
            if let responseString = responseObject as? String {
                self!.show("Subscribed channels", message: responseString)
            }
            
        }, failure: { [weak self](response, error) in
            let description = error?.localizedDescription
            self!.show("Error", message:description!)
        })
    }
    
    private func show(title:String, message:String) {
        UIAlertView(title:title,
                  message: message,
                 delegate: nil,
        cancelButtonTitle: "Ok").show()
    }
}