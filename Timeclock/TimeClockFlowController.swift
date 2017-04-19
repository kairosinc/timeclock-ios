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
        case idle
        case capturing
        case displayingOptions
        case employeeIDEnrolment
        case employeeIDVerification
    }
    
    var configuration: Configuration? {
        didSet {
            guard let configuration = configuration else { return }
            configuration.clockOptionsViewController.delegate = self
            configuration.idleViewController.delegate = self
            configuration.captureViewController.delegate = self
            configuration.employeeIDViewController.delegate = self
            
            setUIState(.idle)
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
    
    func setUIState(_ state: AppState) {
        
        guard let configuration = self.configuration else { return }

        for timeClockViewController in configuration.viewControllers {
            var vc = timeClockViewController
            vc.appState = state
        }
    }
    
    func setupComplete() {
        guard let compositeViewController = compositeViewController else { return }
        if let setupVC = compositeViewController.presentedViewController as? SetupViewController {
            setupVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupFailed() {
        guard let compositeViewController = compositeViewController else { return }

        let alert = UIAlertController(title: "Setup Failed", message: "Please check your Client ID and internet connection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if let presentedVC = compositeViewController.presentedViewController {
            presentedVC.present(alert, animated: true, completion: nil)
        } else {
            compositeViewController.present(alert, animated: true, completion: nil)
        }
        
        let _ = try? Keychain.delete(identifier: "client_id")
        Timeclock.Configuration.removeFromUserDefaults()
        WFMAPI.heimdallr()?.clearAccessToken()
    }
}

extension TimeClockFlowController: ClockOptionsDelegate {
    func clock(_ option: ClockOptions) {
        setUIState(.idle)
    }
    
    func cancel() {
        setUIState(.idle)
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
            setUIState(.capturing)
        } else {
            configuration?.employeeIDViewController.punchData = PunchData()
            setUIState(.employeeIDVerification)
        }
    }
}

extension TimeClockFlowController: CaptureDelegate {
    func imageCaptured(_ punchData: PunchData?) {
        
        func employeeIDVerification(_ punchData: PunchData?) {
            if let _ = punchData?.subjectID {
                setUIState(.employeeIDVerification)
            } else if let _ = punchData?.image {
                setUIState(.employeeIDEnrolment)
            }
            
            self.configuration?.employeeIDViewController.punchData = punchData
            self.configuration?.captureViewController.punchData = nil
        }
        
        
        if
            let config = Timeclock.Configuration.fromUserDefaults(),
            let punchData = punchData,
            let subjectID = punchData.subjectID,
            let confidence = punchData.confidence,
            !config.enable2FA && confidence > 0.75 {
            
            DataController.sharedController?.fetchEmployee(subjectID, completion: { (managedObject, error) in
                
                if let employee = managedObject as? Employee {
                    var mutablePunchData = punchData
                    mutablePunchData.employee = employee
                    
                    self.setUIState(.displayingOptions)
                    self.configuration?.captureViewController.punchData = nil
                    self.configuration?.clockOptionsViewController.punchData = mutablePunchData
                    
                } else {
                    employeeIDVerification(punchData)
                }
            })
            

            
        } else {
            employeeIDVerification(punchData)
        }
    }
    
    func timedOut() {
        setUIState(.employeeIDVerification)
        self.configuration?.captureViewController.punchData = nil
    }
}

extension TimeClockFlowController: EmployeeIDDelegate {
    func idEntered(_ punchData: PunchData?) {
        setUIState(.displayingOptions)
        self.configuration?.employeeIDViewController.punchData = nil
        self.configuration?.clockOptionsViewController.punchData = punchData
    }
    
    func cancelled() {
        setUIState(.idle)
        self.configuration?.employeeIDViewController.punchData = nil
    }
}
