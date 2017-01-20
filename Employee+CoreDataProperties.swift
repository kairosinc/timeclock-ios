//
//  Employee+CoreDataProperties.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import CoreData


extension Employee {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
//        return NSFetchRequest<Employee>(entityName: "Employee");
//    }

    @NSManaged public var badgeNumber: String?
    @NSManaged public var firstName: String?
}
