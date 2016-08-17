//
//  IdleViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol IdleDelegate {
    func dismiss()
}

class IdleViewController: UIViewController {
    
    //MARK: Properties
    var delegate: IdleDelegate?
    
    @IBAction func tapGestureRecognizerAction(sender: AnyObject) {
        delegate?.dismiss()
    }
}

extension IdleViewController: TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .Idle:
            return 1
        default:
            return 0
        }
    }
}
