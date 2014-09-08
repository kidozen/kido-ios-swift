//
//  KZApplicationAuthentication.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 7/29/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

struct KZCredentials {
    let username : String?
    let password : String?
    let provider : String
}

class KZApplicationAuthentication : KZObject {
    
    var applicationConfiguration : KZApplicationConfiguration?
    var tenantMarketPlace : String?
    var strictSSL : Bool?
    var applicationKey : String?
    
    var didFinishAuthenticationCb : kzDidFinishCb?
    var didFailAuthenticationCb : kzDidFailCb?
    
    let tokenController : KZTokenController
    
    var identityProvider : KZIdentityProviderProtocol?
    var kzUser : KZUser?
    
    var networkManager : KZNetworkManager
    var authenticated : Bool?
    
    var lastCredentials : KZCredentials?
    
    init(applicationConfiguration:KZApplicationConfiguration?, tenantMarketPlace:String?, strictSSL:Bool?)
    {
        
        self.applicationConfiguration = applicationConfiguration
        self.tenantMarketPlace = tenantMarketPlace
        self.strictSSL = strictSSL
        self.authenticated = false
        self.tokenController = KZTokenController()
        
        self.networkManager = KZNetworkManager(baseURLString:applicationConfiguration!.authConfig!.oauthTokenEndpoint!,
                strictSSL: strictSSL!, tokenController:nil)
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        
        super.init()
        
        self.configureTokenRefresh()
    }
    
    func authenticate(#user : String,
        provider : String,
        password : String,
        success : kzDidFinishCb?,
        failure: kzDidFailCb?)
    {
        self.didFinishAuthenticationCb = success
        self.didFailAuthenticationCb = failure
        self.lastCredentials = KZCredentials(username: user, password: password, provider: provider)
        
        authenticate(lastCredentials!)
            
    }
    
    /// Authentication using application Key
    func handleAuthentication(#applicationKey:String?,
                                  willStartCb:kzVoidCb?,
                                      success:kzDidFinishCb?,
                                      failure:kzDidFailCb?)
    {
        self.applicationKey = applicationKey
        let applicationKeyParameters = self.dictionaryForTokenUsingApplicationKey()
        
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        
        networkManager.POST(path:"",
                        parameters: applicationKeyParameters,
                           success: {
                                [weak self] (operation, responseObject) in
                                    self!.tokenController.currentAuthentication = .KZApplicationKey

                                    let responseDictionary = responseObject as? Dictionary<String, AnyObject>
                                    let accessToken = (responseDictionary!["access_token"] as AnyObject?) as? String
                            
                                    self!.tokenController.updateAccessToken(accessToken, accessTokenKey:self!.accessTokenCacheKey())
                            
                                    self!.tokenController.parseAndUpdateClaimsAndRoles()
                            
                                    self!.kzUser = KZUser(claims:self!.tokenController.currentClaims, roles:self!.tokenController.currentRoles)
                            
                                    if let outerSuccess = success {
                                        outerSuccess(response: operation, responseObject: responseObject)
                                    }
                                }, failure: {
                                        (operation, error) in
                                    if let outerFailure = failure {
                                            outerFailure(response: operation, error: error)
                                    }
            
                                })
    }
    
    func doPassiveAuthentication(success:kzDidFinishCb?, failure:kzDidFailCb?)
    {
        self.didFinishAuthenticationCb = success
        self.didFailAuthenticationCb = failure
        
        let rootController = UIApplication.sharedApplication().delegate!.window??.rootViewController
        
        let passiveUrlString = self.applicationConfiguration!.authConfig!.signInUrl
        self.lastCredentials = KZCredentials(username: nil, password: nil, provider: "SOCIAL")
        
        let passiveAuthVC = KZPassiveAuthViewController(urlString: passiveUrlString,
                success: {
                    [weak self] (token:String?, refreshToken:String?) -> () in
                        self!.updateTokens(token, refreshToken: refreshToken, ipToken:nil, currentAuthentication: .KZPassiveAuthentication)
                        self!.didFinishAuthenticationCb?(response: nil, responseObject: self!.kzUser)
                    
                }, failure: { (error:NSError?) in
                    if let outerFailure = failure {
                        outerFailure(response:nil, error: error)
                    }
                })
        
        let webNavigation = UINavigationController(rootViewController: passiveAuthVC)
        rootController?.presentViewController(webNavigation, animated: true, completion: nil)
        
    }

    private func updateTokens(accessToken : String!, refreshToken:String!, ipToken:String!, currentAuthentication : KZCurrentAuthentication)
    {
        authenticated = true
        self.tokenController.currentAuthentication = currentAuthentication
        self.tokenController.updateAccessToken(accessToken, accessTokenKey: self.accessTokenCacheKey())
        self.tokenController.updateRefreshToken(refreshToken)
        self.tokenController.updateIPToken(ipToken, ipTokenKey: self.ipTokenCacheKey())
        self.tokenController.parseAndUpdateClaimsAndRoles()
        self.kzUser = KZUser(claims:self.tokenController.currentClaims, roles:self.tokenController.currentRoles)
    }
    
    private func refreshPassiveToken(success:kzDidFinishCb?,
                                     failure:kzDidFailCb?)
    {
        networkManager.POST(   path: self.applicationConfiguration?.authConfig?.oauthTokenEndpoint,
                         parameters: self.dictionaryForPassiveToken(),
                            success: success,
                            failure: failure)
    }

    private func dictionaryForPassiveToken() -> Dictionary<String, String> {
        return ["grant_type" : "refresh_token",
                "client_id" : self.applicationConfiguration!.domain!,
                "client_secret" : self.applicationKey!,
                "scope" : self.applicationConfiguration!.authConfig!.applicationScope!,
                "refresh_token" : self.tokenController.refreshToken!]
    }

    
    private func dictionaryForTokenUsingApplicationKey() -> Dictionary<String, String> {
        let domain = self.applicationConfiguration!.domain!
        let applicationScope = self.applicationConfiguration!.authConfig!.applicationScope!
        
        return ["client_id" : domain,
                "client_secret" : self.applicationKey!,
                "grant_type" : "client_credentials",
                "scope" : applicationScope]
    }

    private func authenticate(credentials:KZCredentials)
    {
        tokenController.loadTokensFromCache(forIpKey: self.ipTokenCacheKey(), accessTokenKey: self.accessTokenCacheKey())
        
        if (tokenController.kzToken? != nil && tokenController.ipToken? != nil) {
            completeAuthenticationFlow()
        } else {
            invokeAuthServices(credentials)
        }
    }
    
    private func invokeAuthServices(credentials:KZCredentials)
    {
        let authServiceScope = applicationConfiguration?.authConfig?.authServiceScope
        let authServiceEndPoint = applicationConfiguration?.authConfig?.authServiceEndpoint
        let applicationScope = applicationConfiguration?.authConfig?.applicationScope
        
        let provider = credentials.provider
        let providerProtocol = applicationConfiguration?.authConfig?.protocolFor(provider)
        let providerIPEndpoint = applicationConfiguration?.authConfig?.endPointFor(provider)
        
        if (identityProvider? == nil) {
            identityProvider = KZIdentityProviderFactory.createProvider(providerProtocol, strictSSL: self.strictSSL)
        }
        
        identityProvider?.initialize(credentials.username, password: credentials.password, scope: authServiceScope)
        networkManager = KZNetworkManager(baseURLString: authServiceEndPoint!, strictSSL: self.strictSSL!, tokenController:nil)
        networkManager.configureResponseSerializer(AFJSONResponseSerializer())
        networkManager.configureRequestSerializer(AFJSONRequestSerializer())
        
        identityProvider?.requestToken(providerIPEndpoint, willStartCb: nil, success: {
            [weak self] ipToken in
            let parameters = [  "wrap_scope" : applicationScope!,
                                "wrap_assertion_format" : "SAML",
                                "wrap_assertion" : ipToken!]
            
            self!.networkManager.POST(path:"", parameters:parameters, success:
                {
                    (operation, responseObject) in
                    
                    let responseDictionary = responseObject as? Dictionary<String, AnyObject>
                    let rawToken = (responseDictionary!["rawToken"] as AnyObject?) as? String
                    
                    // For now, we don't use the refresh token for username/password authentication, but we just
                    // reauthenticate.
                    
                    self!.updateTokens(rawToken, refreshToken: nil, ipToken:ipToken, currentAuthentication: .KZUsernamePassword)
                    self!.didFinishAuthenticationCb?(response: nil, responseObject: self!.kzUser)

                }, failure: {
                    [weak self] (response,error) in
                    self!.didFailAuthenticationCb!(response:response, error:error)
            });
        }, failure: {
            [weak self](response, error) in
            self!.didFailAuthenticationCb!(response:response, error:error)
        })
    }
    
    private func configureTokenRefresh() {
        var tokenRefresher = KZTokenRefresher()
        
        tokenRefresher.refreshUsernameCb = {
            [weak self] (success, failure) in
            self!.tokenController.reset()
            self!.didFinishAuthenticationCb = success
            self!.didFailAuthenticationCb = failure
            self!.authenticate(self!.lastCredentials!)
        }
        
        tokenRefresher.refreshApplicationKeyCb = {
            [weak self] (success, failure) in
            self!.handleAuthentication(applicationKey: self!.applicationKey, willStartCb: nil, success: success, failure: failure)
        }
        
        tokenRefresher.refreshPassiveCb = {
            [weak self] (success, failure) in
            self!.refreshPassiveToken(success, failure: failure)
        }
        
        self.tokenController.tokenRefresher = tokenRefresher
        
        
    }
    
    private func ipTokenCacheKey() -> String!
    {
        return "\(self.tenantMarketPlace!)\(self.lastCredentials?.provider)\(self.lastCredentials?.username)\(self.lastCredentials?.password)-ipToken".md5()
    }
    
    private func accessTokenCacheKey() -> String!
    {
        return "\(self.tenantMarketPlace!)\(self.lastCredentials?.provider)\(self.lastCredentials?.username)\(self.lastCredentials?.password)".md5()
    }
    
    private func completeAuthenticationFlow()
    {
        self.authenticated = true
        self.tokenController.parseAndUpdateClaimsAndRoles()
        self.kzUser = KZUser(claims:self.tokenController.currentClaims, roles:self.tokenController.currentRoles)
        didFinishAuthenticationCb?(response: nil, responseObject: kzUser)
    }
}
