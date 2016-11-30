//
//  WFMAPIError.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 13/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

public enum RaphaAPIError: ErrorType {
    case Known(String)
    case Unknown()
    
    internal static func fromJSONData(data: NSData) -> RaphaAPIError? {
        if let
            wrappedJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? JSONType,
            json = wrappedJSON,
            errorsArray = json["errors"] as? [AnyObject],
            errorDictionary = errorsArray.first as? JSONType,
            errorType = errorDictionary["type"] as? String {
            
            if let userFacingError = userFacingMessageForType(errorType) {
                return RaphaAPIError.Known(userFacingError)
            } else {
                return RaphaAPIError.Known(errorType)
            }

        } else {
            return nil
        }
    }
    
    internal static func fromErrorString(errorString: String) -> RaphaAPIError {
        if let userFacingError = userFacingMessageForType(errorString) {
            return RaphaAPIError.Known(userFacingError)
        } else {
            return RaphaAPIError.Known(errorString)
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
