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
        seriallyUploadPunches()
    }
    
    func seriallyUploadPunches() {
        DataController.sharedController?.fetchPunches(completion: { (punches, error) in
            guard let punches = punches where !punches.isEmpty else { return }
            let startIndex = punches.startIndex
            
            self.uploadPunch(punches, currentIndex: startIndex)
        })
    }
    
    func uploadPunch(punches: [Punch], currentIndex: Int) {
        WFMAPI.punches([punches[currentIndex]], completion: { (error) in
            if let _ = error {
            } else {
                let punchToRemove = punches[currentIndex]
                DataController.sharedController?.deletePunches([punchToRemove], completion: { (error) in })
            }
            
            let newIndex = currentIndex + 1
            if newIndex < punches.endIndex {
                self.uploadPunch(punches, currentIndex: newIndex)
            }

        })
    }
    
    func setupReachability(hostName hostName: String?) {
        
        do {
            let reachability = try hostName == nil ? Reachability.reachabilityForInternetConnection() : Reachability(hostname: hostName!)
            self.reachability = reachability
        } catch ReachabilityError.FailedToCreateWithAddress(_) {
            return
        } catch {
            return
        }
        
        reachability?.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.sync()
            }
        }
        
    }
}
