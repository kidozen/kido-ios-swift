//
//  KZPubSubChannel.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/21/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class KZPubSubChannel : NSObject, SRWebSocketDelegate {
    
    private var wsEndPoint : String!
    private var endPoint : String!
    private var webSocket : SRWebSocket?
    private var tokenController : KZTokenController!
    private var name : String!
    private var networkManager : KZNetworkManager!
    
    private var success : kzDidFinishWebSocketCb?
    private var failure : kzDidFailCb?
    
    init(endPoint:String!, wsEndPoint:String!, name:String!, tokenController:KZTokenController!, strictSSL:Bool!)
    {
        self.endPoint = endPoint
        self.wsEndPoint = wsEndPoint
        self.tokenController = tokenController
        self.name = name
        
        self.networkManager = KZNetworkManager(baseURLString: self.endPoint,
                                                   strictSSL: strictSSL,
                                             tokenController: tokenController)
        
        self.networkManager.configureRequestSerializer(AFJSONRequestSerializer() as AFHTTPRequestSerializer)
        self.networkManager.configureResponseSerializer(AFJSONResponseSerializer() as AFHTTPResponseSerializer)
        
    }

    func subscribe(willStartCb:kzVoidCb?, success:kzDidFinishWebSocketCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.success = success
        self.failure = failure
        
        let url = NSURLRequest(URL: NSURL(string: self.wsEndPoint)!)
        self.webSocket = SRWebSocket(URLRequest: url)
        self.webSocket?.delegate = self
        self.webSocket?.open()
    }
    
    func unsubscribe(willStartCb:kzVoidCb?, success:kzDidFinishWebSocketCb?, failure:kzDidFailCb?)
    {
        willStartCb?()
        self.success = success
        self.failure = failure
        
        self.webSocket?.close()
    }
    
    func publish(object:Dictionary<String, AnyObject>, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.networkManager.POST(path: self.name, parameters: object, success: success, failure: failure)
    }
 
    
    /// delegate
    func webSocketDidOpen(webSocket: SRWebSocket!)
    {
        self.webSocket?.send("bindToChannel::{\"application\":\"local\",\"channel\":\"\(self.name)\"}")
    }

    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!)
    {
        let msg = message as String
        let range = msg.rangeOfString("::", options: .LiteralSearch, range: nil, locale: nil)
        let theMessage = msg.substringFromIndex(range!.startIndex)
        
        var error : NSError?
        let messageData = theMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let jsonDictionary = NSJSONSerialization.JSONObjectWithData(messageData!, options: .MutableContainers, error: &error) as Dictionary<String, String>
        
        if (error? != nil) {
            self.failure?(response: nil, error: error)
        } else {
            self.success?(jsonDictionary)
        }
    }

    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!)
    {
        self.failure?(response: nil, error: error)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool)
    {
        self.success?(["code" : code,
                       "reason" : reason,
                       "wasClean" : wasClean])
    }
   
}