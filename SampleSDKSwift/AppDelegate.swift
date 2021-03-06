//
//  AppDelegate.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import UIKit

let kTenant = "REPLACE_WITH_YOUR_TENANT"
let kApplicationName = "REPLACE_WITH_YOUR_APPLICATION_NAME"
let kApplicationKey = "REPLACE_WITH_YOUR_APP_KEY"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var kzApplication : KZApplication?
    var menuViewController : MenuViewController?
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool
    {
        // Initialize kzApplication
        kzApplication = KZApplication(tenantMarketPlace: kTenant,
            applicationName: kApplicationName,
            applicationKey: kApplicationKey,
            strictSSL: false)
        
        createViewControllers()
        
        kzApplication?.initializeServices(willStartCb:nil, success: { [weak self](response, responseObject) in
            self!.menuViewController!.enableView()
            
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Badge | .Sound | .Alert)


        }, failure: { (response, error) in
            // Alertview
            // Something wrong happened.
        })
        
        return true
    }
    
    func createViewControllers()
    {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        menuViewController = MenuViewController(nibName: "MenuViewController", bundle: nil)

        menuViewController!.kzApplication = kzApplication
        var navMenuVC = UINavigationController(rootViewController: menuViewController!)
        
        self.window!.rootViewController = navMenuVC
        self.window!.makeKeyAndVisible()
    }
        
    
    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        println("My token is \(deviceToken)")
        
        self.menuViewController?.deviceToken = deviceToken.description;
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError!) {
        UIAlertView(title: "Error", message: "\(error)", delegate: nil, cancelButtonTitle: "Ok").show()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        UIAlertView(title: "Push", message: "\(userInfo)", delegate: nil, cancelButtonTitle: "Ok").show()
    }


}

