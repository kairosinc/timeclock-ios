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
//    var lastKnownLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    init() {
//        super.init()
//        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////        guard let location = locations.last else { return }
////        MapDownloader.sharedDownloader.cacheMapsFor(location)
//    }
}

