//
//  SyncScheduler.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 19/12/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Reachability
import UIKit

class SyncScheduler: NSObject {
    var syncTimer: NSTimer?
    var reachability: Reachability?
    
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
            
            setupReachability(hostName: "https://kairos.com")
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
    
    func setupReachability(hostName hostName: String?) {
        
        do {
            let reachability = try hostName == nil ? Reachability.reachabilityForInternetConnection() : Reachability(hostname: hostName!)
            self.reachability = reachability
        } catch ReachabilityError.FailedToCreateWithAddress(_) {
            return
        } catch {}
        
        reachability?.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.sync()
            }
        }
        
    }
}
