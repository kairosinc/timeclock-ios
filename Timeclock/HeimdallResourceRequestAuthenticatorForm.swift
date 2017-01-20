//
//  HeimdallResourceRequestAuthenticatorForm.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 06/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Heimdallr

/// A `HeimdallResourceRequestAuthenticator` which uses the Form Field `Authorization`
/// parameters to authorize a request.
@objc
public class HeimdallResourceRequestAuthenticatorForm: NSObject, HeimdallResourceRequestAuthenticator {
    
    public override init() {
    }
    
    /// Authenticates the given request by setting the `Authorization`
    /// form fields.
    ///
    /// - parameter request: The request to be authenticated.
    /// - parameter accessToken: The access token that should be used for
    ///     authenticating the request.
    ///
    /// - returns: The authenticated request.
    public func authenticateResourceRequest(request: NSURLRequest, accessToken: OAuthAccessToken) -> NSURLRequest {
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        mutableRequest.setHTTPAuthorization(.AccessTokenAuthentication(accessToken))
        return mutableRequest
    }
    
}
