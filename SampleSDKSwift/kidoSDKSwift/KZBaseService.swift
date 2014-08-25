//
//  KZBaseService.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/30/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

class KZBaseService {
    
    internal let networkManager : KZNetworkManager!
    internal let endPoint : String!
    internal let name : String?
    internal weak var tokenController : KZTokenController!
    var strictSSL : Bool?

    /// Always implement init in base classes.
    /// There was a bug with the KZTokenController.
    init (endPoint:String!, name:String?, tokenController:KZTokenController!) {
        self.endPoint = endPoint
        self.name = name != nil ? name : ""
        self.tokenController = tokenController
        self.networkManager = KZNetworkManager(baseURLString: endPoint, strictSSL: true, tokenController:tokenController)
    }

    internal func addAuthorizationHeader()
    {
        // TODO: Must check if we have to add another header.
        networkManager.addAuthorizationHeader(tokenController?.kzToken?)
    }
    
    internal func configureNetworkManager()
    {
        fatalError("Subclasses should override this method")
    }


    func query(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        fatalError("Subclasses should override this method")
    }
    
    func query(#data:Dictionary<String, AnyObject>?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        fatalError("Subclasses should override this method")
    }
    
    
    
    func invoke(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        fatalError("Subclasses should override this method")
    }
    
    func invoke(#data:Dictionary<String, AnyObject>?, willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        fatalError("Subclasses should override this method")
    }

}