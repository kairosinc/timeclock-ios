//
//  JSONable.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 07/12/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

protocol JSONable {
    var jsonValue: JSONType { get }
}
