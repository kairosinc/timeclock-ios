//
//  Employee+CoreDataClass.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import CoreData


public class Employee: NSManagedObject, ManagedObjectType {
    
    static let EntityName = "Employee"
    
    enum Attributes: String {
        case employeeID = "employeeID"
        case firstName = "firstName"
        case lastName = "lastName"
    }
    
    //MARK: Convenience
    class func insertNewInContext(managedObjectContext: NSManagedObjectContext) -> Employee? {
        return NSEntityDescription.insertNewObjectForEntityForName(Employee.EntityName, inManagedObjectContext: managedObjectContext) as? Employee
    }
    
    class func fromJSON(json: JSONType, inContext context: NSManagedObjectContext) -> Employee {
        let employee: Employee = context.insertObject()
        
        employee.employeeID = json[Employee.Attributes.employeeID.rawValue] as? String
        employee.firstName  = json[Employee.Attributes.firstName.rawValue]  as? String
        employee.lastName   = json[Employee.Attributes.lastName.rawValue]   as? String
        
        return employee
    }

}
