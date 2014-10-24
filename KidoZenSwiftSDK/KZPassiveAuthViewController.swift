//
//  KZPassiveAuthViewController.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/13/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

/*!
    This class handles all the flow for passive authentication. When the view
    is loaded, it'll instance a webview and start the request for passive authentication.
    
    A handy way to use passive authentication is not to instance this class directly, but
    to call KZApplicationAuthentication.doPassiveAuthentication() method, which 
    will get your current navigationController and present this ViewController in a 
    modal way.
*/
class KZPassiveAuthViewController : UIViewController, UIWebViewDelegate {
    private let kSuccessPayloadPrefix = "Success payload="
    private let kErrorPayloadPrefix = "Error message="
    
    private var url : NSURL!
    private var success: kzDidFinishPassiveTokenCb?
    private var failure : kzDidFailPassiveTokenCb?
    private var webView : UIWebView!
    private var activityView : UIActivityIndicatorView!
    
    init(urlString:String, success:kzDidFinishPassiveTokenCb?, failure:kzDidFailPassiveTokenCb?) {
        self.url = NSURL(string:urlString)
        
        self.success = success
        self.failure = failure
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadBarButtonItem()
        self.configureWebView()
        self.configureActivityView()
        self.loadRequest()
    }
    

    private func loadRequest()
    {
        let urlRequest = NSURLRequest(URL:self.url)
        self.webView.loadRequest(urlRequest)
    }
    
    private func configureActivityView()
    {
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle:.WhiteLarge)
        self.activityView.color = UIColor.darkGrayColor()
        self.view.addSubview(self.activityView)
        self.activityView.hidesWhenStopped = true
        self.activityView.center = self.webView.center
        self.activityView.stopAnimating()
        self.view.userInteractionEnabled = true
        
    }
    
    private func configureWebView() {
        self.webView =  UIWebView(frame: self.view.frame)
        self.webView.delegate = self
        self.view.addSubview(self.webView)
    }
    
    private func loadBarButtonItem()
    {
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem()
    }
    
    private func cancelBarButtonItem() -> UIBarButtonItem
    {
        return UIBarButtonItem(barButtonSystemItem:.Cancel, target: self, action:"cancelAuth")
    }
    
    internal func cancelAuth()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    /// WebViewDelegate
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool
    {
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView!)
    {
        self.activityView.startAnimating()
        self.view.userInteractionEnabled = false
    }

    func webViewDidFinishLoad(webView: UIWebView!)
    {
        self.activityView.stopAnimating()
        self.view.userInteractionEnabled = true
        if let payload = webView.stringByEvaluatingJavaScriptFromString("document.title") {
            if (payload.hasPrefix(kSuccessPayloadPrefix)) {
                let b64 = payload.stringByReplacingOccurrencesOfString(kSuccessPayloadPrefix, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                let b64Data = NSData(base64EncodedString: b64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let jsonString = NSString(data: b64Data!, encoding: NSUTF8StringEncoding)
                
                let jsonDictionary = NSJSONSerialization.JSONObjectWithData(b64Data!, options: nil, error: nil) as? Dictionary<String, AnyObject>
                
                let accessToken: String? = (jsonDictionary?["access_token"] as AnyObject?) as String?
                let refreshToken: String? = (jsonDictionary?["refresh_token"] as AnyObject?) as String?
                
                self.success?(fullResponse: jsonDictionary!, token: accessToken!, refreshToken: refreshToken!)
                self.dismissViewControllerAnimated(true, completion: nil)
                
                
            } else if (payload.hasPrefix(kErrorPayloadPrefix)) {
                let errorMessage = payload.stringByReplacingOccurrencesOfString(kErrorPayloadPrefix, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                let error = NSError(domain: "KZPassiveAuthenticationError", code: 2, userInfo: ["error message":errorMessage])
                self.handleError(error)
            }
        }
        
    }

    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!)
    {
        self.activityView.stopAnimating()
        self.view.userInteractionEnabled = true
        self.handleError(error)
    }
    
    private func handleError(error:NSError!)
    {
        self.failure?(error:error )
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}