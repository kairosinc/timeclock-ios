//
//  TestEntity.swift
//
//  Created by Tom Hutchinson on 24/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import CoreData

@testable import Timeclock

class TestEntity: NSManagedObject, ManagedObjectType {
    
    static let EntityName = "TestEntity"

    enum Attributes: String {
        case testString = "testStringAttribute"
        case testBool = "testBoolAttribute"
    }
}
