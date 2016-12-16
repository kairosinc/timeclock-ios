//
//  LocationMonitor.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 22/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CoreLocation
import UIKit

class LocationMonitor {
    
    static let sharedMonitor = LocationMonitor()
    
    let locationManager = CLLocationManager()
    
    init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
}

