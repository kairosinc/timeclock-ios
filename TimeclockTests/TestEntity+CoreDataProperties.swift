//
//  TestEntity+CoreDataProperties.swift
//
//  Created by Tom Hutchinson on 23/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TestEntity {

    @NSManaged var testStringAttribute: String?
    @NSManaged var testBoolAttribute: NSNumber?

}
