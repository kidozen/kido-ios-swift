//
//  TasksViewController.swift
//  SampleApp
//
//  Created by Nicolas Miyasato on 12/3/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import UIKit
import KidoZen

class TasksViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl : UISegmentedControl!
    
    var kzApplication : KZApplication? {
        didSet {
            self.storageService = self.kzApplication?.storage("tasks")
        }
    }
    
    private var storageService : KZStorage!
    private var tasks : Array<AnyObject>?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTasks(segmentedControl.selectedSegmentIndex)

    }
    
    private func reloadTasks(index:Int) {
        switch(index) {
        case 0:
            self.loadTask(taskType: "Completed")
        case 1:
            self.loadTask(taskType: "Pending")
        case 2:
            self.loadAllTasks()
        default:
            self.loadAllTasks()
        }    }
    
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTask")
        self.navigationItem.titleView = segmentedControl

    }
    
    
    @IBAction func tabChangedValue(sender: UISegmentedControl) {
        
        self.reloadTasks(sender.selectedSegmentIndex)
        
    }
    
    func addTask() {
        let addTaskVC = AddTaskViewController(nibName:"AddTaskViewController", bundle:nil)
        addTaskVC.storageService = storageService
        let navVC = UINavigationController(rootViewController: addTaskVC)
        
        self.navigationController?.presentViewController(navVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    private func loadAllTasks() {
        storageService.all(willStartCb: { [weak self] in
            self!.startLoading()
            
            
            }, success: { [weak self](response, responseObject) in
                self!.stopLoading()
                self!.tasks = responseObject as? Array<AnyObject>
                self!.tableView.reloadData()
                
            }, failure: { [weak self] (response, error) in
                self!.stopLoading()
        })
    }
    
    private func loadTask(#taskType:String) {
        var completedBoolString = "true"
        if (taskType != "Completed") {
            completedBoolString = "false"
        }
        
        let queryString = "{\"completed\" : \(completedBoolString)}"
        storageService.query(queryString: queryString, willStartCb: { [weak self]  in
            self!.activityIndicator.startAnimating()
            
        }, success: { [weak self] (response, responseObject) in
            
            self!.stopLoading()
            self!.tasks = responseObject as? Array<AnyObject>
            self!.tableView.reloadData()

        }) { [weak self] (response, error) in
            
            self!.stopLoading()
        }
        
    }
    
    private func startLoading() {
        self.activityIndicator.startAnimating()
        self.view.userInteractionEnabled = false
    }
    
    private func stopLoading() {
        self.activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
    }
    
    
    // Mark: UITableViewDatasource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tasks != nil) {
            return tasks!.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let kTasksCell = "kTasksCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(kTasksCell) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: kTasksCell)
        }
        
        // Configuring the cell
        var dictionary: NSDictionary = tasks![indexPath.row] as NSDictionary
        
        cell!.textLabel!.text = dictionary["title"] as? String
        cell!.detailTextLabel!.text = dictionary["desc"] as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var vc = TasksDetailViewController(nibName:"TasksDetailViewController", bundle:nil)
        vc.loadView()
        let dictionary : NSDictionary = tasks![indexPath.row] as NSDictionary
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.configure(dictionary, kzApplication: kzApplication!, storage: storageService)
        
    }


}