//
//  TimeClockFlowController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

struct TimeClockFlowController {
    
    var compositeViewController: TimeClockCompositeViewController?
    
    enum AppState {
        case Idle
        case Capturing
        case DisplayingOptions
        case EmployeeIDEnrolment(image: UIImage)
        case EmployeeIDVerification(employeeID: String)
    }
    
    var configuration: Configuration? {
        didSet {
            guard let configuration = configuration else { return }
            configuration.clockOptionsViewController.delegate = self
            configuration.idleViewController.delegate = self
            configuration.captureViewController.delegate = self
            configuration.employeeIDViewController.delegate = self
            
            setUIState(.Idle)
        }
    }
    
    struct Configuration {
        let clockOptionsViewController: ClockOptionsViewController
        let idleViewController: IdleViewController
        let captureViewController: CaptureViewController
        let employeeIDViewController: EmployeeIDViewController
        
        var viewControllers: [TimeClockViewController] {
            return [
                clockOptionsViewController,
                idleViewController,
                captureViewController,
                employeeIDViewController
            ]
        }
    }
    
    func setUIState(state: AppState) {
        
        guard let configuration = self.configuration else { return }

        for timeClockViewController in configuration.viewControllers {
            var vc = timeClockViewController
            vc.appState = state
        }
    }
    
    func setupComplete() {
        guard let compositeViewController = compositeViewController else { return }
        if let setupVC = compositeViewController.presentedViewController as? SetupViewController {
            setupVC.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func setupFailed() {
        guard let compositeViewController = compositeViewController else { return }

        let alert = UIAlertController(title: "Setup Failed", message: "Please check your Client ID and internet connection", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        compositeViewController.presentViewController(alert, animated: true, completion: nil)
        let _ = try? Keychain.delete(identifier: "client_id")
        WFMAPI.heimdallr.clearAccessToken()
    }
}

extension TimeClockFlowController: ClockOptionsDelegate {
    func clock(option: ClockOptions) {
        setUIState(.Idle)
    }
}

extension TimeClockFlowController: IdleDelegate {
    func dismiss() {
        setUIState(.Capturing)
        configuration?.captureViewController.punchData = PunchData()
        configuration?.captureViewController.startCapturing()
    }
}

extension TimeClockFlowController: CaptureDelegate {
    func imageCaptured(punchData: PunchData?) {
        
        configuration?.employeeIDViewController
        if let employeeID = punchData?.subjectID {
            setUIState(.EmployeeIDVerification(employeeID: employeeID))
        } else if let image = punchData?.image {
            setUIState(.EmployeeIDEnrolment(image: image))
        }
        
        self.configuration?.captureViewController.punchData = nil
        self.configuration?.employeeIDViewController.punchData = punchData
    }
    
    func timedOut() {
    }
}

extension TimeClockFlowController: EmployeeIDDelegate {
    func idEntered(punchData: PunchData?) {
        setUIState(.DisplayingOptions)
        self.configuration?.employeeIDViewController.punchData = nil
        self.configuration?.clockOptionsViewController.punchData = punchData
    }
    
    func cancelled() {
        setUIState(.Idle)
    }
}
