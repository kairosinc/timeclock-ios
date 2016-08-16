//
//  ClockOptionsViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

enum ClockOptions: Int {
    case In = 0
    case Out = 1
    case BreakStart = 2
    case BreakEnd = 3
}

protocol ClockOptionsDelegate {
    func clock(option: ClockOptions)
}

class ClockOptionsViewController: UIViewController {
    
    //MARK: Properties
    var delegate: ClockOptionsDelegate?
    
    //MARK: IBAction
    @IBAction func clockOptionTouchUpInside(sender: AnyObject) {
        guard let
            tag = sender.tag,
            selectedOption = ClockOptions(rawValue: tag)
        else {
            return
        }
        
        delegate?.clock(selectedOption)
    }
}
