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
open class HeimdallResourceRequestAuthenticatorForm: NSObject, HeimdallResourceRequestAuthenticator {
    
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
    open func authenticateResourceRequest(_ request: URLRequest, accessToken: OAuthAccessToken) -> URLRequest {
        var mRequest = request
        mRequest.setHTTPAuthorization(.accessTokenAuthentication(accessToken))
        return mRequest
    }
    
}
