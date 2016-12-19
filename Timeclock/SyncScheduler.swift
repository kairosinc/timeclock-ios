//
//  SyncScheduler.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 19/12/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

class SyncScheduler: NSObject {
    var syncTimer: NSTimer?
    
    var syncInterval: Double? {
        didSet {
            guard let syncInterval = syncInterval else {
                syncTimer?.invalidate()
                return
            }
            
            if let syncTimer = syncTimer {
                syncTimer.invalidate()
            }
            
            syncTimer = NSTimer.scheduledTimerWithTimeInterval(
                syncInterval,
                target: self,
                selector: #selector(sync),
                userInfo: nil,
                repeats: true)
        }
    }
    
    func sync() {
        WFMAPI.employees() { (employees, error) in }
        
        DataController.sharedController?.fetchPunches(completion: { (punches, error) in
            guard let punches = punches where !punches.isEmpty else { return }
            WFMAPI.punches(punches, completion: { (error) in
                if let _ = error {
                } else {
                    DataController.sharedController?.deletePunches(punches, completion: { (error) in })
                }
            })
        })
    }
}
