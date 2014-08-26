//
//  ServicesViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/26/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class ServicesViewController : UIViewController {
    
    @IBOutlet weak var serviceTextField: UITextField!
    @IBOutlet weak var jsonParametersTextView: UITextView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var service : KZService?
    var kzToken : String?
    var kzApplication : KZApplication?

    override func viewDidLoad() {
        self.title = "Service SDK Demo"
    }
    
    private func query(parameters:AnyObject?)
    {
        activityIndicator.startAnimating()

        service = kzApplication?.LOBServiceWithName(serviceTextField.text)
        
        service!.invokeMethod("get", data:parameters, willStartCb: { () -> () in
            
            }, success: { [weak self](response, responseObject) -> () in
                self!.responseTextView.text = "response is \(responseObject!)"
                self!.activityIndicator.stopAnimating()
                
            }) { [weak self](response, error) -> () in
                self!.showError(error)
        }
    }
    
    private func post(parameters:AnyObject?) {
        activityIndicator.startAnimating()
        
        service = kzApplication?.LOBServiceWithName(serviceTextField.text)
        
        service!.invokeMethod("post", data:parameters, willStartCb: { () -> () in
            
            }, success: { [weak self](response, responseObject) -> () in
                self!.responseTextView.text = "response is \(responseObject!)"
                self!.activityIndicator.stopAnimating()
                
            }) { [weak self](response, error) -> () in
                self!.showError(error)
        }
        
    }
    
    @IBAction func queryWithParameters(sender: AnyObject) {
    
        self.query(self.getCurrentParameters())
    }
    
    
    @IBAction func queryWithNoParameters(sender: AnyObject)
    {
        self.query(nil)
    }
    
    
    @IBAction func invokeWithParameters(sender: AnyObject) {
        self.post(self.getCurrentParameters())
    }
    
    @IBAction func invokeWithNoParameters(sender: AnyObject) {
        self.post(nil)
    }
 
    private func showError(error:NSError?)
    {
        self.activityIndicator.stopAnimating()
        UIAlertView(  title: "Error while querying",
            message: error?.localizedDescription,
            delegate:nil,
            cancelButtonTitle: "OK").show()
        
    }
    
    private func getCurrentParameters() -> Dictionary<String, AnyObject>?
    {
        var jsonString  = jsonParametersTextView.text
        var any  = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error : NSError?
        var parameters = NSJSONSerialization.JSONObjectWithData(any!, options:NSJSONReadingOptions.MutableContainers, error: &error) as? Dictionary<String, AnyObject>
        
        return parameters
    }
    
    
}