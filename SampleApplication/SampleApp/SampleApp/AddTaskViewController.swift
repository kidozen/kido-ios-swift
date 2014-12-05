//
//  AddTaskViewController.swift
//  SampleApp
//
//  Created by Nicolas Miyasato on 12/4/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import UIKit
import KidoZen

class AddTaskViewController : UIViewController  {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var featureButton: UIButton!
    
    @IBOutlet weak var bugFeatureButton: UIButton!
    
    var storageService : KZStorage?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        self.title = "New Task"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel,
                                                                             target: self,
                                                                             action: "cancel")
        
        
        self.bugFeatureButton.backgroundColor = UIColor.lightGrayColor()
        self.featureButton.backgroundColor = UIColor.whiteColor()
        self.bugFeatureButton.selected = true
        self.featureButton.selected = false

        self.registerForKeyboardNotifications()
        addHideTapGestureRecognizer()
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func cancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func addHideTapGestureRecognizer() {
        let gr = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(gr)
    }
    
    func hideKeyboard() {
        if (self.titleTextField.isFirstResponder()) {
            self.titleTextField.resignFirstResponder()
        } else if (self.descriptionTextView.isFirstResponder()) {
            self.descriptionTextView.resignFirstResponder()
        }
    }
    
    func keyboardDidShow(notification:NSNotification) {
        let keyboardHeight = self.heightForKeyboard(notification)
        
        self.scrollView.frameHeight = UIScreen.mainScreen().bounds.size.height - keyboardHeight
        
        self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.okButton.frameMaxY + 5)
    }
    
    func keyboardWillHide(notification:NSNotification) {
       
            self.scrollView.frameHeight = UIScreen.mainScreen().bounds.size.height
            self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.okButton.frameMaxY + 5)
            self.scrollView.scrollRectToVisible(self.okButton.frame, animated: true)
    }

    func heightForKeyboard(notification:NSNotification) -> CGFloat {
        let info = notification.userInfo
        let value = info![UIKeyboardFrameBeginUserInfoKey] as NSValue
        let size = value.CGRectValue().size
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return size.height
        } else {
            return size.width
        }
        
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool
    {
        self.descriptionTextView.becomeFirstResponder()
        return false
    }
 
    @IBAction func bugPressed(sender:AnyObject) {
        self.bugFeatureButton.selected = true
        self.featureButton.selected = false
    
        self.bugFeatureButton.backgroundColor = UIColor.lightGrayColor()
        self.featureButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func featurePressed(sender:AnyObject) {
        self.bugFeatureButton.selected = false
        self.featureButton.selected = true
    
        self.bugFeatureButton.backgroundColor = UIColor.whiteColor()
        self.featureButton.backgroundColor = UIColor.lightGrayColor()
    
    }

    @IBAction func okPressed(sender: AnyObject) {

        if (countElements( self.titleTextField.text) > 0 &&
            countElements(self.descriptionTextView.text) > 0 ) {
                let category = self.bugFeatureButton.selected == true ? "Bug" : "Feature"

                let params = ["title" : self.titleTextField.text,
                    "desc" : self.descriptionTextView.text,
                    "category" : category,
                    "completed" :false]
                
                storageService?.create(object: params, options: nil, willStartCb: nil, success: { (response, responseObject) -> () in
                    UIAlertView(title: "", message: "Task Created", delegate: nil, cancelButtonTitle: "Ok").show()
                    self.cancel()
                    
                }, failure: { (response, error) -> () in
                    UIAlertView(title: "", message: "Error while creating task", delegate: nil, cancelButtonTitle: "Ok").show()
                })
        }
        
        self.hideKeyboard()
    }
}
