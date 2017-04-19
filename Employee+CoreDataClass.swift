//
//  Employee+CoreDataClass.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import CoreData


open class Employee: NSManagedObject, ManagedObjectType {
    
    static let EntityName = "Employee"
    
    enum Attributes: String {
        case badgeNumber = "BADGE_NUMBER"
        case firstName = "FIRST_NAME"
    }
    
    //MARK: Convenience
    class func insertNewInContext(_ managedObjectContext: NSManagedObjectContext) -> Employee? {
        return NSEntityDescription.insertNewObject(forEntityName: Employee.EntityName, into: managedObjectContext) as? Employee
    }
    
    class func fromJSON(_ json: JSONType, inContext context: NSManagedObjectContext) -> Employee {
        let employee: Employee = context.insertObject()
        
        if let badgeNumber = json[Employee.Attributes.badgeNumber.rawValue] as? NSNumber {
            employee.badgeNumber = badgeNumber.stringValue
        }
        
        employee.firstName  = json[Employee.Attributes.firstName.rawValue]  as? String
        
        return employee
    }

}
