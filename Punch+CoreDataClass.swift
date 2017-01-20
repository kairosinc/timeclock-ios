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

public class Punch: NSManagedObject, ManagedObjectType {

    static let EntityName = "Punch"
    
    //MARK: Convenience
    class func insertNewInContext(managedObjectContext: NSManagedObjectContext) -> Punch? {
        let some = NSEntityDescription.insertNewObjectForEntityForName(Punch.EntityName, inManagedObjectContext: managedObjectContext)
        return some as? Punch
    }
    
}

extension Punch: JSONable {
    var jsonValue: JSONType {
        
        var dictionary = [
            "timestamp_utc": timestampUTC!,
            "timestamp_local": timestampLocal!,
            "clock_offset": NSNumber(short: clockOffset),
            "timezone_offset": NSNumber(short: timezoneOffset),
            "timezone_name": timezoneName!,
            "timezone_dst": NSNumber(short: timezoneDST),
            "badge_number": badgeNumber!,
            "badge_number_valid": Int(badgeNumberValid),
            "direction": direction!,
            "online": online!
        ]
        
        if let facerecImageData = facerecImageData where facerecImageData.characters.count > 0 {
            dictionary["facerec_transaction_id"] = "000000"
            
            dictionary["facerec"] = [
            "image_type": "image/jpeg",
            "image_data": facerecImageData,
            "confidence": confidence ?? "",
            "subject_id": subjectID ?? ""
            ]
        }
        
        return dictionary
    }
}
