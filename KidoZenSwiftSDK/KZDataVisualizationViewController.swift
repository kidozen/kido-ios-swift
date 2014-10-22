//
//  KZDataVisualizationViewController.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/16/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation


/**

*/
class KZDataVisualizationViewController : UIViewController, UIWebViewDelegate {

    
    var successCb : kzVoidCb?
    var failureCb : kzErrorCb?
    
    private var downloadURLString : String!
    private var dataVizName : String!
    private var tenantName : String!
    private var applicationName : String!
    
    private var networkManager : KZNetworkManager!
    
    private var webView : UIWebView!
    private var activityView : UIActivityIndicatorView!
    private var progressView : UIProgressView!
    
    
    init(applicationConfig:KZApplicationConfiguration,
                   appAuth:KZApplicationAuthentication,
                    tenant:String,
                 strictSSL:Bool,
               dataVizName:String)
    {
        self.dataVizName = dataVizName
        self.tenantName = tenant
        self.applicationName = applicationConfig.name
        self.downloadURLString = "https://\(applicationConfig.name!).\(applicationConfig.domain!)/api/v2/visualizations/\(dataVizName)/app/download?type=mobile"

        self.networkManager = KZNetworkManager(baseURLString: "",
                                                   strictSSL: strictSSL,
                                             tokenController: appAuth.tokenController)
        self.progressView = UIProgressView(progressViewStyle: .Default)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.dataVizName
        
        self.loadBarButtonItem()
        self.configureWebView()
        self.configureActivityView()
        self.configureProgressView()
        self.downloadZipFile()
        
    }
    
    private func downloadZipFile()
    {
        let url = NSURL(string: self.downloadURLString)
        let path = self.tempDirectory() + "/" + self.dataVizName + ".zip"
        
        let urlPath = NSURL(fileURLWithPath: path)
        
        self.networkManager.download(url: url!, destination: path, successCb: { [weak self](response, responseObject) -> () in
            self!.unzipFile(urlPath: urlPath!)
            //    [safeMe.progressView removeFromSuperview];
            
            }, failureCb : {(response, error) -> () in
                print("Error is \(error), \(response)")
        })
        
    }

    private func unzipFile(#urlPath:NSURL) {
        var error : NSError?
        let zipFile = ZZArchive(URL: urlPath, error: &error)
        
        if (error == nil) {
            
            let fm = NSFileManager.defaultManager()
            let destination = NSURL(fileURLWithPath: self.tempDirectory() + "/" + self.dataVizName)
            fm.createDirectoryAtURL(destination!, withIntermediateDirectories: true, attributes: nil, error: nil)

            for nextEntry  in zipFile.entries {
                let targetPath : NSURL = destination!.URLByAppendingPathComponent(nextEntry.fileName)
                println("targetPath is \(targetPath)")
                println("S_IFDIR \(S_IFDIR)")
                println("nextEntry.fileMode is \(nextEntry.fileMode)")
                
                if ((nextEntry.fileMode & S_IFDIR) != 0) {
                    println("entry is directory")
                    
                    var dirError : NSError?
                    fm.createDirectoryAtURL(targetPath, withIntermediateDirectories: true, attributes: nil, error: &dirError)
                    
                    if (dirError != nil) {
                        println("ERror while creating directory is \(dirError)")
                    }
                    
                } else {
                    var dirError : NSError?

                    fm.createDirectoryAtURL(targetPath,
                                    withIntermediateDirectories: true,
                                                     attributes: nil,
                                                          error: &dirError)
                    
                    if (dirError != nil) {
                        println("ERror while creating is \(dirError)")
                    }

                    var data = nextEntry.newDataWithError(&error)
                    var writeError : NSError?
                    
                    if (data.writeToURL(targetPath, options:nil, error: &writeError) == false) {
                        println("Error while creating targetPath \(targetPath), error is \(writeError)")
                    }
                    
                }
            }
        }
    }
    
    private func tempDirectory() -> String
    {
        let paths  = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        return paths[0] as String
        
    }
    
    private func configureProgressView()
    {
        self.view.addSubview(self.progressView)
        self.progressView.center = self.view.center
    }
    
    private func configureActivityView()
    {
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        self.activityView.color = UIColor.darkGrayColor()
        self.activityView.center = self.webView.center
        self.activityView.stopAnimating()
        self.view.userInteractionEnabled = true
    }
    
    private func configureWebView() {
        self.webView = UIWebView(frame: self.view.frame)
        self.webView.delegate = self
        self.view.addSubview(self.webView)
    }
    
    private func loadBarButtonItem() {
        self.navigationItem.leftBarButtonItem = self.closeButton();
    }

    private func closeButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "closeDataVisualization")
    }
    
    func closeDataVisualization() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    
//    optional func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
//    optional func webViewDidStartLoad(webView: UIWebView)
//    optional func webViewDidFinishLoad(webView: UIWebView)
//    optional func webView(webView: UIWebView, didFailLoadWithError error: NSError)
    

}
