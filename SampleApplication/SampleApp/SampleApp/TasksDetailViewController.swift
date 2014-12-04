//
//  TasksDetailViewController.swift
//  SampleApp
//
//  Created by Nicolas Miyasato on 12/3/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import UIKit
import Kidozen

class TasksDetailViewController : UIViewController {
 
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configure(dictionary:NSDictionary) {
        let title = dictionary["title"] as String
        let desc = dictionary["desc"] as String
        
        if let value: String? = dictionary["category"] as? String {
            self.categoryLabel.text = value
        }
        
        self.titleLabel.text = title
        self.descriptionTextView.text = desc
        
    }
    

    @IBAction func completeTask(sender:UIButton) {
        
    }
    
    @IBAction func deleteTask(sender:UIButton) {
        
    }
    
    @IBAction func sendTask(sender:UIButton) {
        
    }
}