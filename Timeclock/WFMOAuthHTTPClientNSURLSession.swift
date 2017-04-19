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
open class WFMOAuthHTTPClientNSURLSession: NSObject, HeimdallrHTTPClient {
    let urlSession: URLSession
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
        urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default),
        oAuthClientCredentials: OAuthClientCredentials) {
        
        self.urlSession = urlSession
        self.oAuthClientCredentials = oAuthClientCredentials
    }
    
    /// Sends the given request.
    ///
    /// - parameter request: The request to be sent.
    /// - parameter completion: A callback to invoke when the request completed.
    public func sendRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Swift.Error?) -> ()) {
        
        var mutableRequest = request

        let paramsToAdd: String
        if
            let bodyData = request.httpBody,
            let params = parametersFromBody(bodyData) {
            
            paramsToAdd = params
        } else {
            paramsToAdd = ""
        }
        
        
        let url = "http://example.com/some?" + paramsToAdd
        let urlComponents = URLComponents(string: url)
        let queryItems = urlComponents?.queryItems
        let username = queryItems?.filter({$0.name == "username"}).first?.value
        let password = queryItems?.filter({$0.name == "password"}).first?.value
        let clientID = queryItems?.filter({$0.name == "client_id"}).first?.value
        let siteID = queryItems?.filter({$0.name == "site_id"}).first?.value
        let company = queryItems?.filter({$0.name == "company"}).first?.value
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
        
        if let company = company {
            paramDict["company"] = company
        }
        
        if let grantType = grantType {
            paramDict["grant_type"] = grantType
        }
        
        if let refreshToken = refreshToken {
            paramDict["refresh_token"] = refreshToken
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: paramDict, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        
        mutableRequest.setHTTPBody(parameters: ["auth": jsonString! as AnyObject])
        let task = urlSession.dataTask(with: mutableRequest, completionHandler: completion)
        task.resume()
    }
    
    /// Pulls the authentication parameters from the header
    ///
    /// - parameter body: The reqest body.
    fileprivate func parametersFromBody(_ body: Data) -> String? {
        let parameters = String(data: body, encoding: String.Encoding.utf8)
        return parameters
    }
    
}
