//
//  EmployeeIDViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 06/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

class EmployeeIDViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var employeeIDLabel: UILabel!
    
    
    //MARK: IBAction
    @IBAction func numPadTouchUpInside(sender: AnyObject) {
        guard let tag = sender.tag else { return }
        numberEntered(tag)
    }
    
    @IBAction func clearTouchUpInside(sender: AnyObject) {
    }
    
    @IBAction func doneTouchUpInside(sender: AnyObject) {
    }
    
    //MARK: Properties
    var containerView: UIView?
    
    //MARK: Methods
    func numberEntered(number: Int) {
        let existingText: String
        if let existingUnwrappedValue = employeeIDLabel.text {
            existingText = existingUnwrappedValue
        } else {
            existingText = ""
        }
        
        employeeIDLabel.text = existingText + String(number)
    }
}

extension EmployeeIDViewController: TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .EmployeeID:
            return 1
        default:
            return 0
        }
    }
}
