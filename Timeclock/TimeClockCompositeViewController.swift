//
//  TimeClockViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

class TimeClockCompositeViewController: UIViewController {

    //MARK: IBOutlet
    @IBOutlet weak var clockOptionsView: UIView!
    @IBOutlet weak var idleView: UIView!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var employeeIDView: UIView!
    
    
    //MARK: Properties
    var clockOptionsViewController: ClockOptionsViewController?
    var idleViewController: IdleViewController?
    var captureViewController: CaptureViewController?
    var employeeIDViewController: EmployeeIDViewController?
    
    var flowController = TimeClockFlowController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let
            clockOptionsViewController = clockOptionsViewController,
            idleViewController = idleViewController,
            captureViewController = captureViewController,
            employeeIDViewController = employeeIDViewController
        else {
            return
        }
        
        flowController.configuration = TimeClockFlowController.Configuration(
            clockOptionsViewController: clockOptionsViewController,
            idleViewController: idleViewController,
            captureViewController: captureViewController,
            employeeIDViewController: employeeIDViewController)
        
        flowController.setUIState(.Idle)
    }

    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        switch segueIdentifier {
        case "embedIdleViewController":
            guard let destination = segue.destinationViewController as? IdleViewController else { break }
            idleViewController = destination
            break
        case "embedCaptureViewController":
            guard let destination = segue.destinationViewController as? CaptureViewController else { break }
            captureViewController = destination
            break
            
        case "embedClockOptionsViewController":
            guard let destination = segue.destinationViewController as? ClockOptionsViewController else { break }
            clockOptionsViewController = destination
            break
            
        case "embedEmployeeIDViewController":
            guard let destination = segue.destinationViewController as? EmployeeIDViewController else { break }
            employeeIDViewController = destination
            break
            
        default:
            break
        }
    }

}
