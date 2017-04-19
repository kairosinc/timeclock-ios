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
    var syncTimer: Timer?
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
            
            syncTimer = Timer.scheduledTimer(
                timeInterval: syncInterval,
                target: self,
                selector: #selector(sync),
                userInfo: nil,
                repeats: true)
            
            setupReachability(hostName: "https://kairos.com")
        }
    }
    
    func sync() {
        _ = WFMAPI.employees() { (employees, error) in }
        seriallyUploadPunches()
    }
    
    func seriallyUploadPunches() {
        DataController.sharedController?.fetchPunches(completion: { (punches, error) in
            guard let punches = punches, !punches.isEmpty else { return }
            let startIndex = punches.startIndex
            
            self.uploadPunch(punches, currentIndex: startIndex)
        })
    }
    
    func uploadPunch(_ punches: [Punch], currentIndex: Int) {
        _ = WFMAPI.punches([punches[currentIndex]], completion: { (error) in
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
    
    func setupReachability(hostName: String?) {
        self.reachability = Reachability(hostname: hostName!)
        
        reachability?.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.sync()
            }
        }
        
    }
}
