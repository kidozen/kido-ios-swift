//
//  KZDataVisualizationViewController.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/16/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation


class KZDataVisualizationViewController : UIViewController, UIWebViewDelegate {

//
//    @property (nonatomic, strong) UIWebView *webView;
//    @property (nonatomic, strong) UIActivityIndicatorView *activityView;
//    @property (nonatomic, strong) UIProgressView *progressView;
//    

    
    var successCb : kzVoidCb?
    var errorCb : kzErrorCb?
    
    private var downloadURLString : String!
    private var dataVizName : String!
    private var tenantName : String!
    private var applicationName : String!
    
    private var networkManager : KZNetworkManager!
    private weak var tokenController : KZTokenController?
    
    
    private var webView : UIWebView!
    private var activityView : UIActivityIndicatorView!
    private var progressView : UIProgressView!
    
    
    init(applicationConfig:KZApplicationConfiguration,
                   appAuth:KZApplicationAuthentication,
                    tenant:String,
                 strictSSL:Bool,
           tokenController:KZTokenController,
               dataVizName:String)
    {
        self.downloadURLString = "api/v2/visualizations/\(dataVizName)/app/download?type=mobile"
        self.tokenController = tokenController
        self.dataVizName = dataVizName
        self.tenantName = tenant
        self.applicationName = applicationConfig.name

        self.networkManager = KZNetworkManager(baseURLString: applicationConfig.html5Url!,
                                                   strictSSL: strictSSL,
                                             tokenController: tokenController)
        self.progressView = UIProgressView(progressViewStyle: .Default)
        super.init()
        
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
        let path = self.tempDirectory() + self.dataVizName + ".zip"
        let url = NSURL(string: self.downloadURLString)
        
        self.networkManager.download(url: url, destination: path, successCb: { (response, responseObject) -> () in
            //    [safeMe unzipFileAtPath:path folderName:[self dataVizDirectory]];
            //    [safeMe.progressView removeFromSuperview];
            
            }, failureCb : {(response, error) -> () in
                // handleError
        })
        
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
//    
//    optional func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
//    optional func webViewDidStartLoad(webView: UIWebView)
//    optional func webViewDidFinishLoad(webView: UIWebView)
//    optional func webView(webView: UIWebView, didFailLoadWithError error: NSError)
    

}
