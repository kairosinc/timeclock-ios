//
//  WFMAPIError.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 13/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

public enum KairosAPIError: ErrorType {
    case Known(String)
    case Unknown()
    
    internal static func fromJSONData(data: NSData) -> KairosAPIError? {
        if let
            wrappedJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? JSONType,
            json = wrappedJSON,
            errorsArray = json["errors"] as? [AnyObject],
            errorDictionary = errorsArray.first as? JSONType,
            errorType = errorDictionary["type"] as? String {
            
            if let userFacingError = userFacingMessageForType(errorType) {
                return KairosAPIError.Known(userFacingError)
            } else {
                return KairosAPIError.Known(errorType)
            }

        } else {
            return nil
        }
    }
    
    internal static func fromErrorString(errorString: String) -> KairosAPIError {
        if let userFacingError = userFacingMessageForType(errorString) {
            return KairosAPIError.Known(userFacingError)
        } else {
            return KairosAPIError.Known(errorString)
        }
    }
    
    private static func userFacingMessageForType(errorType: String) -> String? {
        return userFacingErrors[errorType]
    }
    
    private static let userFacingErrors: [String: String] = {
        return [
            "DuplicateUidError" : "A user with this email address already exists.",
            "Could not authorize grant" : "Incorrect email or password."
        ]
    }()
}
