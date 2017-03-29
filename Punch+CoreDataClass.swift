//
//  Punch+CoreDataClass.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/11/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

open class Punch: NSManagedObject, ManagedObjectType {

    static let EntityName = "Punch"
    
    //MARK: Convenience
    class func insertNewInContext(_ managedObjectContext: NSManagedObjectContext) -> Punch? {
        let some = NSEntityDescription.insertNewObject(forEntityName: Punch.EntityName, into: managedObjectContext)
        return some as? Punch
    }
    
}

extension Punch: JSONable {
    var jsonValue: JSONType {
        
        var dictionary: JSONType = [
            "timestamp_utc": timestampUTC!,
            "timestamp_local": timestampLocal!,
            "clock_offset": NSNumber(value: clockOffset as Int16),
            "timezone_offset": NSNumber(value: timezoneOffset as Int16).intValue,
            "timezone_name": timezoneName!,
            "timezone_dst": NSNumber(value: timezoneDST as Int16),
            "badge_number": badgeNumber!,
            "badge_number_valid": badgeNumberValid.intValue(),
            "direction": direction!,
            "online": online!
        ]
        
        if let facerecImageData = facerecImageData, facerecImageData.characters.count > 0 {
            dictionary["facerec_transaction_id"] = "000000"
            
            let faceRecDict: [String: Any] = [
                "image_type": "image/jpeg",
                "image_data": facerecImageData,
                "confidence": confidence ?? "",
                "subject_id": subjectID ?? ""
            ]
            
            dictionary["facerec"] = faceRecDict
        }
        
        return dictionary
    }
}
