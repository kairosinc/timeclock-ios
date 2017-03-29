//
//  WFMAPIError.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 13/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

public enum KairosAPIError: Error {
    case known(String)
    case unknown()
    
    internal static func fromJSONData(_ data: Data) -> KairosAPIError? {
        if
            let wrappedJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONType,
            let json = wrappedJSON,
            let errorsArray = json["errors"] as? [AnyObject],
            let errorDictionary = errorsArray.first as? JSONType,
            let errorType = errorDictionary["type"] as? String {
            
            if let userFacingError = userFacingMessageForType(errorType) {
                return KairosAPIError.known(userFacingError)
            } else {
                return KairosAPIError.known(errorType)
            }

        } else {
            return nil
        }
    }
    
    internal static func fromErrorString(_ errorString: String) -> KairosAPIError {
        if let userFacingError = userFacingMessageForType(errorString) {
            return KairosAPIError.known(userFacingError)
        } else {
            return KairosAPIError.known(errorString)
        }
    }
    
    fileprivate static func userFacingMessageForType(_ errorType: String) -> String? {
        return userFacingErrors[errorType]
    }
    
    fileprivate static let userFacingErrors: [String: String] = {
        return [
            "DuplicateUidError" : "A user with this email address already exists.",
            "Could not authorize grant" : "Incorrect email or password."
        ]
    }()
}
