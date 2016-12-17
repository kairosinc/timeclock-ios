//
//  Punch+CoreDataProperties.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/11/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Punch {

    @NSManaged public var timestampUTC: String?
    @NSManaged public var timestampLocal: String?
    @NSManaged public var clockOffset: Int16
    @NSManaged public var timezoneOffset: Int16
    @NSManaged public var timezoneName: String?
    @NSManaged public var timezoneDST: Int16
    @NSManaged public var badgeNumber: String?
    @NSManaged public var badgeNumberValid: Bool
    @NSManaged public var direction: String?
    @NSManaged public var online: String?
    @NSManaged public var facerecTransactionID: String?
    @NSManaged public var facerecImageType: String?
    @NSManaged public var facerecImageData: String?
    @NSManaged public var subjectID: String?
    @NSManaged public var confidence: NSNumber?
}
