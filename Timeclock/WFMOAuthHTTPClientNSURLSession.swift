//
//  WFMOAuthHTTPClientNSURLSession.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 06/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Heimdallr
import Moya

/// An HTTP client that uses NSURLSession.
@objc
public class WFMOAuthHTTPClientNSURLSession: NSObject, HeimdallrHTTPClient {
    let urlSession: NSURLSession
    let oAuthClientCredentials: OAuthClientCredentials
    /// Initializes a new client.
    ///
    /// - parameter urlSession: The NSURLSession to use.
    ///     Default: `NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())`.
    ///
    /// - parameter oAuthClientCredentials: The OAauth credentials to add to the request.
    ///
    /// - returns: A new client using the given `NSURLSession`.
    public init(
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        urlSession: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()),
        oAuthClientCredentials: OAuthClientCredentials) {
        
        self.urlSession = urlSession
        self.oAuthClientCredentials = oAuthClientCredentials
    }
    
    /// Sends the given request.
    ///
    /// - parameter request: The request to be sent.
    /// - parameter completion: A callback to invoke when the request completed.
    public func sendRequest(
        request: NSURLRequest,
        completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        
        let paramsToAdd: String
        if let
            bodyData = request.HTTPBody,
            params = parametersFromBody(bodyData) {
            paramsToAdd = params
        } else {
            paramsToAdd = ""
        }
        
        
        let url = "http://example.com/some?" + paramsToAdd
        let urlComponents = NSURLComponents(string: url)
        let queryItems = urlComponents?.queryItems
        let username = queryItems?.filter({$0.name == "username"}).first?.value
        let password = queryItems?.filter({$0.name == "password"}).first?.value
        let clientID = queryItems?.filter({$0.name == "client_id"}).first?.value
        let siteID = queryItems?.filter({$0.name == "site_id"}).first?.value
        let grantType = queryItems?.filter({$0.name == "grant_type"}).first?.value
        let refreshToken = queryItems?.filter({$0.name == "refresh_token"}).first?.value
        
        var paramDict: [String: String] = [:]
        
        if let username = username {
            paramDict["username"] = username
        }
        
        if let password = password {
            paramDict["password"] = password
        }
        
        if let clientID = clientID {
            paramDict["client_id"] = clientID
        }
        
        if let siteID = siteID {
            paramDict["site_id"] = siteID
        }
        
        if let grantType = grantType {
            paramDict["grant_type"] = grantType
        }
        
        if let refreshToken = refreshToken {
            paramDict["refresh_token"] = refreshToken
        }
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDict, options: [])
        let jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding)
        
        mutableRequest.setHTTPBody(parameters: ["auth": jsonString!])
        let task = urlSession.dataTaskWithRequest(mutableRequest, completionHandler: completion)
        task.resume()
    }
    
    /// Pulls the authentication parameters from the header
    ///
    /// - parameter body: The reqest body.
    private func parametersFromBody(body: NSData) -> String? {
        let parameters = String(data: body, encoding: NSUTF8StringEncoding)
        return parameters
    }
    
}
