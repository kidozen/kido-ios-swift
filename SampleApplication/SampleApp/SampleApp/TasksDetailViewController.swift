//
//  TasksDetailViewController.swift
//  SampleApp
//
//  Created by Nicolas Miyasato on 12/3/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import UIKit
import KidoZen

class TasksDetailViewController : UIViewController {
 
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    private var taskId : String?
    private var details : Dictionary<NSObject, AnyObject>?
    
    var kzApplication : KZApplication?
    var storage : KZStorage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configure(dictionary:NSDictionary, kzApplication:KZApplication, storage:KZStorage) {
        self.details = dictionary
        
        let title = dictionary["title"] as String
        let desc = dictionary["desc"] as String
        
        if let value: String? = dictionary["category"] as? String {
            self.categoryLabel.text = value
        }
        
        self.titleLabel.text = title
        self.descriptionTextView.text = desc
        taskId = dictionary["_id"] as? String
        self.kzApplication = kzApplication
        self.storage = storage
        
    }
    

    @IBAction func completeTask(sender:UIButton) {
        var updatedDictionary = Dictionary<NSObject, AnyObject>()
        updatedDictionary = details!
        updatedDictionary["completed"] = 1
        
        self.storage?.update(usingId: taskId!, objectToUpdate: updatedDictionary, willStartCb: { () -> () in
            
        }, success: { (response, responseObject) -> () in
            UIAlertView(title: "", message: "Task Completed!", delegate: nil, cancelButtonTitle: "Ok").show()

        }, failure: { (response, error) -> () in
            UIAlertView(title: "Error", message: "\(error)", delegate: nil, cancelButtonTitle: "Ok").show()
        })
    }
    
    @IBAction func deleteTask(sender:UIButton) {
        self.storage?.delete(usingId: taskId!, willStartCb: nil, success: { (response, responseObject) -> () in
            UIAlertView(title: "", message: "Task Deleted!", delegate: nil, cancelButtonTitle: "Ok").show()

            }, failure: { (response, error) -> () in
                UIAlertView(title: "Error", message: "\(error)", delegate: nil, cancelButtonTitle: "Ok").show()

        })
        
    }
    
    @IBAction func sendTask(sender:UIButton) {
        
    }
}