//
//  MainViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/31/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import UIKit


class DataSourceViewController : UIViewController {

    @IBOutlet weak var queryNoParametersButton: UIButton!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var dataSourceName: UITextField!
    @IBOutlet weak var jsonParametersTextView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ds : KZDatasource?
    var kzToken : String?
    
    weak var kzApplication : KZApplication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func enableInteraction()
    {
        self.view.userInteractionEnabled = true
        activityIndicator.stopAnimating()

    }
    
    @IBAction func queryNoParametersPressed(sender: AnyObject)
    {
        activityIndicator.startAnimating()
        
        ds = kzApplication?.datasource(dataSourceName.text)
        
        ds!.query(willStartCb: nil, success: {
            [weak self] (response, responseObject) -> () in
                self!.textView.text = "response is \(responseObject!)"
                self!.activityIndicator.stopAnimating()
            
        }, failure: { [weak self](response, error) -> () in
            self!.activityIndicator.stopAnimating()
            UIAlertView(  title: "Error while authenticating",
                message: error?.localizedDescription,
                delegate:nil,
                cancelButtonTitle: "OK").show()

        })
        let a = ["helo" : "value"]
        kzApplication?.loggingService?.write(a, message: "aesfwe", level: .LogLevelVerbose, willStartCb: { () -> () in
            println("To start writing log")
        }, success: {
            (response, responseObject) in
            println("Did finish writing log \(responseObject)")
            
        }, failure: { (response, error) in
            println("Error \(error)")
        })
    }
    
    @IBAction func queryWithParametersPressed(sender: AnyObject) {

        activityIndicator.startAnimating()

        var jsonString  = jsonParametersTextView.text
        var any  = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error : NSError?
        var parameters = NSJSONSerialization.JSONObjectWithData(any!, options:NSJSONReadingOptions.MutableContainers, error: &error) as? Dictionary<String, AnyObject>

        
        ds = kzApplication?.datasource(dataSourceName.text)
        
        ds!.query(      data: parameters,
                 willStartCb: nil,
                     success:
            {
                [weak self]  (response, responseObject) -> () in
                    self!.textView.text = "response is \(responseObject!)"
                    self!.activityIndicator.stopAnimating()
            }, failure:
            {
                [weak self](response, error) -> () in
                
                    self!.activityIndicator.stopAnimating()
                    UIAlertView(  title: "Error while authenticating",
                    message: error?.localizedDescription,
                    delegate:nil,
                    cancelButtonTitle: "OK").show()

            })
        
    }
    
    
    @IBAction func dismissKeyboard(sender: AnyObject)
    {
        if (dataSourceName.isFirstResponder())
        {
            dataSourceName.resignFirstResponder()
        }
        
        if (jsonParametersTextView.isFirstResponder())
        {
            jsonParametersTextView.resignFirstResponder()
        }
    }
    
}
