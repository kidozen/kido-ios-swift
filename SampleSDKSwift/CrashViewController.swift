//
//  CrashViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/28/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class CrashViewController : UIViewController {
    var kzApplication : KZApplication?
    
    @IBAction func crashButtonPressed(sender: AnyObject) {
        kzApplication?.enableCrashReporter()
        
        let array = []
//        println("\(array[1])")
        
        
    }
}
