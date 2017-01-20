//
//  WFMOAuthAccessTokenParser.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 29/11/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Heimdallr

public class WFMOAuthAccessTokenParser: NSObject, OAuthAccessTokenParser {
    
    public func parse(data: NSData) throws -> OAuthAccessToken {
        
        guard let token = OAuthAccessToken.decodeWFMResponse(data: data) else {
            throw NSError(domain: HeimdallrErrorDomain, code: HeimdallrErrorInvalidData, userInfo: nil)
        }
        
        return token
    }
    
}

extension OAuthAccessToken {
    public class func decodeWFMResponse(json: [String: AnyObject]) -> OAuthAccessToken? {
        func toNSDate(timeIntervalSinceNow: NSTimeInterval?) -> NSDate? {
            return timeIntervalSinceNow.map { timeIntervalSinceNow in
                return NSDate(timeIntervalSinceNow: timeIntervalSinceNow)
            }
        }
        
        guard let accessToken = json["access_token"] as? String,
            tokenType = json["token_type"] as? String else {
                return nil
        }
        
        let expiresAt = (json["expires_in"] as? NSTimeInterval).flatMap(toNSDate)
        let refreshToken = json["refresh_token"] as? String
        
        return OAuthAccessToken(accessToken: accessToken, tokenType: tokenType,
                                expiresAt: expiresAt, refreshToken: refreshToken)
    }
    
    public class func decodeWFMResponse(data data: NSData) -> OAuthAccessToken? {
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)),
            jsonDictionary = json as? [String: AnyObject],
            authDictionary = jsonDictionary["auth"] as? [String: AnyObject]
        else {
            return nil
        }
        
        return decodeWFMResponse(authDictionary)
    }
}
