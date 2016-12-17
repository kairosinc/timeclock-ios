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
        case EmployeeIDEnrolment
        case EmployeeIDVerification
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
    
    func cancel() {
        setUIState(.Idle)
    }
}

extension TimeClockFlowController: IdleDelegate {
    func dismiss() {
        guard
            let config = Timeclock.Configuration.fromUserDefaults()
        else {
            return
        }
        
        if config.enableFacialRecognition {
            configuration?.captureViewController.punchData = PunchData()
            configuration?.captureViewController.startCapturing()
            setUIState(.Capturing)
        } else {
            setUIState(.EmployeeIDVerification)
        }
    }
}

extension TimeClockFlowController: CaptureDelegate {
    func imageCaptured(punchData: PunchData?) {
        
        if let
            config = Timeclock.Configuration.fromUserDefaults(),
            punchData = punchData,
            confidence = punchData.confidence
        where !config.enable2FA && confidence > 0.75 {
            
            setUIState(.DisplayingOptions)
            self.configuration?.captureViewController.punchData = nil
            self.configuration?.clockOptionsViewController.punchData = punchData
            
        } else {
            if let _ = punchData?.subjectID {
                setUIState(.EmployeeIDVerification)
            } else if let _ = punchData?.image {
                setUIState(.EmployeeIDEnrolment)
            }
            
            self.configuration?.employeeIDViewController.punchData = punchData
            self.configuration?.captureViewController.punchData = nil
        }
    }
    
    func timedOut() {
        setUIState(.EmployeeIDVerification)
        self.configuration?.captureViewController.punchData = nil
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
        self.configuration?.employeeIDViewController.punchData = nil
    }
}
