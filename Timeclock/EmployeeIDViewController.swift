//
//  EmployeeIDViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 06/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

class EmployeeIDViewController: UIViewController {

    //MARK: IBAction
    @IBAction func numPadTouchUpInside(sender: AnyObject) {
        guard let tag = sender.tag else { return }
        numberEntered(tag)
    }
    
    @IBAction func clearTouchUpInside(sender: AnyObject) {
    }
    
    @IBAction func doneTouchUpInside(sender: AnyObject) {
    }
    
    //MARK: Methods
    func numberEntered(number: Int) {
        
    }
}
