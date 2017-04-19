//
//  WFMOAuthAccessTokenParser.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 29/11/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Heimdallr

open class WFMOAuthAccessTokenParser: NSObject, OAuthAccessTokenParser {
    
    open func parse(data: Data) throws -> OAuthAccessToken {
        
        guard let token = OAuthAccessToken.decodeWFMResponse(data: data) else {
            throw NSError(domain: HeimdallrErrorDomain, code: HeimdallrErrorInvalidData, userInfo: nil)
        }
        
        return token
    }
    
}

extension OAuthAccessToken {
    public class func decodeWFMResponse(_ json: [String: AnyObject]) -> OAuthAccessToken? {
        func toNSDate(_ timeIntervalSinceNow: TimeInterval?) -> Date? {
            return timeIntervalSinceNow.map { timeIntervalSinceNow in
                return Date(timeIntervalSinceNow: timeIntervalSinceNow)
            }
        }
        
        guard let accessToken = json["access_token"] as? String,
            let tokenType = json["token_type"] as? String else {
                return nil
        }
        
        let expiresAt = (json["expires_in"] as? TimeInterval).flatMap(toNSDate)
        let refreshToken = json["refresh_token"] as? String
        
        return OAuthAccessToken(accessToken: accessToken, tokenType: tokenType,
                                expiresAt: expiresAt, refreshToken: refreshToken)
    }
    
    public class func decodeWFMResponse(data: Data) -> OAuthAccessToken? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)),
            let jsonDictionary = json as? [String: AnyObject],
            let authDictionary = jsonDictionary["auth"] as? [String: AnyObject]
        else {
            return nil
        }
        
        return decodeWFMResponse(authDictionary)
    }
}
