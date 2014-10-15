//
//  MainViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/31/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import UIKit
import KidoZen

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
        self.title = "DataSouce SDK Demo"
    }
    
    
    @IBAction func queryNoParametersPressed(sender: AnyObject)
    {
        activityIndicator.startAnimating()
        
        ds = kzApplication?.datasource(name: dataSourceName.text)
        
        ds!.query(willStartCb: nil, success: {
            [weak self] (response, responseObject) -> () in
                self!.textView.text = "response is \(responseObject!)"
                self!.activityIndicator.stopAnimating()
            
        }, failure: { [weak self](response, error) -> () in
            self!.showError(error)
        })
    }
    
    @IBAction func queryWithParametersPressed(sender: AnyObject) {

        activityIndicator.startAnimating()

        var parameters = self.getCurrentParameters()

        ds = kzApplication?.datasource(name: dataSourceName.text)
        
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
                self!.showError(error)
            })
        
    }

    @IBAction func invokeWithParameters(sender: AnyObject) {
        activityIndicator.startAnimating()
        
        var parameters = self.getCurrentParameters()
        
        ds = kzApplication?.datasource(name: dataSourceName.text)
        
        ds!.invoke(data: parameters,
            willStartCb: nil,
            success:
            {
                [weak self]  (response, responseObject) -> () in
                self!.textView.text = "response is \(responseObject!)"
                self!.activityIndicator.stopAnimating()
            }, failure:
            {
                [weak self](response, error) -> () in
                
                self!.showError(error)
        })
    }
    
    @IBAction func invokeWithoutParameters(sender: AnyObject) {
        activityIndicator.startAnimating()
        
        ds = kzApplication?.datasource(name: dataSourceName.text)
        
        ds!.invoke(willStartCb: nil, success: {
            [weak self] (response, responseObject) -> () in
            self!.textView.text = "response is \(responseObject!)"
            self!.activityIndicator.stopAnimating()
            
            }, failure: { [weak self](response, error) -> () in
                self!.showError(error)
        })
    }
    
    private func getCurrentParameters() -> Dictionary<String, AnyObject>?
    {
        var jsonString  = jsonParametersTextView.text
        var any  = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error : NSError?
        var parameters = NSJSONSerialization.JSONObjectWithData(any!, options:NSJSONReadingOptions.MutableContainers, error: &error) as? Dictionary<String, AnyObject>
        
        return parameters
    }
    
    private func showError(error:NSError?)
    {
        self.activityIndicator.stopAnimating()
        UIAlertView(  title: "Error while querying",
            message: error?.localizedDescription,
            delegate:nil,
            cancelButtonTitle: "OK").show()
    
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
