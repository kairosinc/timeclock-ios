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
        
        view.backgroundColor = UIColor.kairosDarkGrey()
        
        flowController.compositeViewController = self
        
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
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.flowController = flowController
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.boolForKey("logout") {
            defaults.setBool(false, forKey: "logout")
            defaults.synchronize()
            let _ = try? Keychain.delete(identifier: "config_client_id")
            let _ = try? Keychain.delete(identifier: "config_site_id")
            let _ = try? Keychain.delete(identifier: "config_username")
            let _ = try? Keychain.delete(identifier: "config_password")
            WFMAPI.heimdallr()?.clearAccessToken()
            showSetup()
        }
        
        guard
            let _ = WFMAPI.configClientID(), let _ = Configuration.fromUserDefaults()
        else {
            showSetup()
            return
        }
    }
    
    func showSetup() {
        let storyboard = UIStoryboard(name: "Setup", bundle: nil)
        if let setupVC = storyboard.instantiateInitialViewController() {
            presentViewController(setupVC, animated: true, completion: nil)
        }
    }

    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        segue.destinationViewController.view.backgroundColor = UIColor.kairosGrey()
        
        switch segueIdentifier {
        case "embedIdleViewController":
            guard let destination = segue.destinationViewController as? IdleViewController else { break }
            idleViewController = destination
            idleViewController?.containerView = idleView
            break
        case "embedCaptureViewController":
            guard let destination = segue.destinationViewController as? CaptureViewController else { break }
            captureViewController = destination
            captureViewController?.containerView = captureView
            break
            
        case "embedClockOptionsViewController":
            guard let destination = segue.destinationViewController as? ClockOptionsViewController else { break }
            clockOptionsViewController = destination
            clockOptionsViewController?.containerView = clockOptionsView
            break
            
        case "embedEmployeeIDViewController":
            guard let destination = segue.destinationViewController as? EmployeeIDViewController else { break }
            employeeIDViewController = destination
            employeeIDViewController?.containerView = employeeIDView
            break
            
        default:
            break
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

}
