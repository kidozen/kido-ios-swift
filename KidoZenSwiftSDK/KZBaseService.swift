//
//  KZBaseService.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/30/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

public class KZBaseService {
    
    internal let networkManager : KZNetworkManager
    internal let endPoint : String
    internal let name : String
    internal weak var tokenController : KZTokenController!
    var strictSSL : Bool? {
        didSet {
            networkManager.strictSSL = strictSSL!
        }
    }

    /// Always implement init in base classes.
    /// There was a bug with the KZTokenController.
    init (endPoint:String, name:String, tokenController:KZTokenController) {
        self.endPoint = endPoint
        self.name = name
        self.tokenController = tokenController
        self.networkManager = KZNetworkManager(baseURLString: endPoint, strictSSL: true, tokenController:tokenController)
    }

    internal func addAuthorizationHeader()
    {
        // TODO: Must check if we have to add another header.
        networkManager.addAuthorizationHeader(tokenController.kzToken)
    }
    
    internal func configureNetworkManager()
    {
        fatalError("Subclasses should override this method")
    }


    public func query(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        fatalError("Subclasses should override this method")
    }
    
    public func invoke(#willStartCb:kzVoidCb?, success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        fatalError("Subclasses should override this method")
    }

}