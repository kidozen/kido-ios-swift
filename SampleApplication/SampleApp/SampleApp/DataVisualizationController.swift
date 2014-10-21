//
//  DataVisualizationController.swift
//  SampleApp
//
//  Created by Nicolas Miyasato on 10/20/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import UIKit
import KidoZen

class DataVisualizationController: UIViewController {
    
    var applicationConfig: KZApplicationConfiguration!
    var applicationAuth : KZApplicationAuthentication!
    var kzApplication : KZApplication!
    
    @IBOutlet weak var dataVizName: UITextField!
    @IBOutlet weak var serverNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DataVisualization"
    }
    
    @IBAction func showDataViz(sender: AnyObject) {
        
        if (countElements(dataVizName.text) > 0) {
//            KZApplication showDataVisualization(name:dataVizName.text, success:)
        }
    }
    
    
}