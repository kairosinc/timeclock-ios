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

@objc(Punch)
public class Punch: NSManagedObject, ManagedObjectType {

    static let EntityName = "Punch"
    
    enum Attributes: String {
        case badgeNumber = "badge_number"
        case firstName = "first_name"
    }
    
    //MARK: Convenience
    class func insertNewInContext(managedObjectContext: NSManagedObjectContext) -> Punch? {
        return NSEntityDescription.insertNewObjectForEntityForName(Punch.EntityName, inManagedObjectContext: managedObjectContext) as? Punch
    }
    
}
