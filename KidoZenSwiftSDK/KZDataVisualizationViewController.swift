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
    private var bytesWritten : UILabel!
    
    private var credentials : KZCredentials!
    private weak var tokenController : KZTokenController?
    
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
        self.credentials = appAuth.lastCredentials
        
        self.networkManager = KZNetworkManager(baseURLString: "",
                                                   strictSSL: strictSSL,
                                             tokenController: appAuth.tokenController)
        self.tokenController = appAuth.tokenController
        self.bytesWritten = UILabel()

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
        self.downloadZipFile()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.configureBytesWritten()
    }
    
    private func configureBytesWritten() {
        self.bytesWritten.frame = CGRectMake(0, 0, self.view.frame.size.width, 40)

        self.view.addSubview(self.bytesWritten)
        self.bytesWritten.center = self.view.center;
        self.bytesWritten.font = UIFont(name: "Helvetica", size: 14)
        self.bytesWritten.textColor = UIColor.grayColor()
        self.bytesWritten.textAlignment = .Center
        
        var fr = self.bytesWritten.frame
        fr.origin.y = self.activityView.frame.origin.y + self.activityView.frame.size.height + 5.0
        self.bytesWritten.frame = fr;

    }
    
    private func downloadZipFile()
    {
        let url = NSURL(string: self.downloadURLString)
        let path = self.tempDirectory() + "/" + self.dataVizName + ".zip"
        
        let urlPath = NSURL(fileURLWithPath: path)
        var progress : Int64 = 0
        self.activityView.startAnimating()
        
        self.networkManager.download(url: url!,
                             destination: path,
                                progressCb: { [weak self] (progress) in
                                    
                                    if (self!.bytesWritten.superview == nil) {
                                        self!.configureBytesWritten()
                                    }
                                    
                                    let value = progress / 1024
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self!.bytesWritten.text = NSString(format: "%d kBytes", value)
                                    })

                            },
                                 successCb: { [weak self](response, responseObject) -> () in
                                    
                                        self!.unzipFile(urlPath: urlPath!)
                                        self!.replacePlaceHolders()
                                        self!.loadWebView()
                                        self!.bytesWritten.removeFromSuperview()

            }, failureCb : { [weak self] (response, error) -> () in
                
                self!.handleError(error)
                self!.bytesWritten.removeFromSuperview()
                self!.activityView.stopAnimating()
        })
        
    }
    
    private func replacePlaceHolders() {
        let indexUrl = self.indexFileURL()
        
        var error : NSError?

        var data = NSData(contentsOfURL: indexUrl)
        
        var indexString = String(contentsOfURL: indexUrl, encoding: NSUTF8StringEncoding, error: &error)
        
        if (error != nil) {
            self.handleError(error)
        }
        
        let options = self.stringOptionsForTokenRefresh()
        let marketPlace = "\"\(self.tenantName)\""
        let appName = "\"\(self.applicationName)\""
        
        indexString = indexString?.stringByReplacingOccurrencesOfString("{{:options}}", withString: options, options:NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        indexString = indexString?.stringByReplacingOccurrencesOfString("{{:marketplace}}", withString: marketPlace, options:NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        indexString = indexString?.stringByReplacingOccurrencesOfString("{{:name}}", withString: appName, options:NSStringCompareOptions.CaseInsensitiveSearch, range: nil)

        var writeError: NSError?
        
        indexString?.writeToURL(indexUrl, atomically: false, encoding: NSUTF8StringEncoding, error: &writeError)
        if (writeError != nil) {
            self.handleError(writeError)
        }
        
    }

    private func loadWebView() {
        self.webView.loadRequest(NSURLRequest(URL: self.indexFileURL()))
    }

    private func unzipFile(#urlPath:NSURL) {
        var error : NSError?
        let zipFile = ZZArchive(URL: urlPath, error: &error)
        
        if (error == nil) {
            
            let fm = NSFileManager.defaultManager()
            let destination = NSURL(fileURLWithPath: self.dataVizDirectory())
            fm.createDirectoryAtURL(destination!, withIntermediateDirectories: true, attributes: nil, error: nil)

            for nextEntry in zipFile.entries {
                let targetPath : NSURL = destination!.URLByAppendingPathComponent(nextEntry.fileName)

                let name : String = nextEntry.fileName

                let isDirectory = name.substringFromIndex(name.endIndex.predecessor()) == "/"
                
                if (( (nextEntry.fileMode & S_IFDIR) > 0) || isDirectory ) {
                    
                    self.createIfDoesNotExist(targetPath)
                    
                } else {
                    
                    // Just in case, we check whether we need to
                    self.createIfDoesNotExist(targetPath.URLByDeletingLastPathComponent!)
                    
                    var data = nextEntry.newDataWithError(&error)
                    var writeError : NSError?
                    
                    if (data.writeToURL(targetPath, options:nil, error: &writeError) == false) {
                        self.handleError(writeError)
                    }
                    
                }
            }
        }
    }
    
    private func createIfDoesNotExist(targetPath:NSURL) {
        let fm = NSFileManager.defaultManager()

        if (!fm.fileExistsAtPath(targetPath.path!)) {
            
            var dirError : NSError?
            fm.createDirectoryAtURL(targetPath,
                    withIntermediateDirectories: true,
                                     attributes: nil,
                                          error: &dirError)
            
            if (dirError != nil) {
                self.handleError(dirError)
            }
            
        }
    }
    
    private func tempDirectory() -> String
    {
        let paths  = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        return paths[0] as String
        
    }
    
    private func dataVizDirectory() -> String {
        return self.tempDirectory() + "/" + self.dataVizName
    }
    
    private func dataVizFileNamePath() -> String {
        return self.tempDirectory() + "/" + self.dataVizName + ".zip"
    }
    
    
    private func indexFileURL() -> NSURL {
        let indexFileString = self.dataVizDirectory() + "/index.html"
        return NSURL(fileURLWithPath: indexFileString)!
    }
    
    private func configureActivityView()
    {
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        self.view.addSubview(self.activityView)
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
        
        self.networkManager.cancelAllRequests()
        let fm = NSFileManager.defaultManager()
        fm.removeItemAtPath(self.dataVizDirectory(), error: nil)
        fm.removeItemAtPath(self.dataVizFileNamePath(), error: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func handleError(error:NSError?) {
        var message : String?
        
        if (error != nil) {
            message = "Error while loading visualization. Please try again later. Error is \(error!)"
        } else {
            message = "Error while loading visualization. Please try again later."
        }
        
        UIAlertView(title: "Could not load visualization", message: message, delegate: nil, cancelButtonTitle: "OK").show()
        
        if (self.failureCb != nil) {
            self.failureCb?(error)
        }
    }
    
    private func stringOptionsForTokenRefresh() -> String {
        
        var obj : Dictionary<String, AnyObject> = Dictionary()
        obj["token"] = self.tokenController?.authenticationResponse

        if (self.credentials.username != nil && self.credentials.password != nil) {
            
            obj["username"] = self.credentials.username!
            obj["password"] = self.credentials.password!
            obj["provider"] = self.credentials.provider
            
        }
        
        let jsonData = NSJSONSerialization.dataWithJSONObject(obj, options: nil, error: nil)
        
        return NSString(data: jsonData!, encoding: NSUTF8StringEncoding)!
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityView.startAnimating()
        self.view.userInteractionEnabled = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        self.activityView.stopAnimating()
        self.view.userInteractionEnabled = true
        self.successCb?()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.activityView.stopAnimating()
        self.view.userInteractionEnabled = false
        self.handleError(error)
    }
    
}
