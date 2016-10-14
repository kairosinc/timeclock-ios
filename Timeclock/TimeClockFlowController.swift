//
//  TimeClockFlowController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

struct TimeClockFlowController {
    
    enum AppState {
        case Idle, Capturing, ProcessingImage, DisplayingOptions, EmployeeIDEnrolment, EmployeeIDVerification
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
}

extension TimeClockFlowController: ClockOptionsDelegate {
    func clock(option: ClockOptions) {
        setUIState(.Idle)
    }
}

extension TimeClockFlowController: IdleDelegate {
    func dismiss() {
        setUIState(.EmployeeIDVerification)
//        setUIState(.Capturing)
//        configuration?.captureViewController.startCapturing()
    }
}

extension TimeClockFlowController: CaptureDelegate {
    func imageCaptured(image: UIImage) {
        print("image captured")
        setUIState(.DisplayingOptions)
    }
    
    func timedOut() {
        
    }
}

extension TimeClockFlowController: EmployeeIDDelegate {
    func idEntered(employeeID: String) {
        setUIState(.DisplayingOptions)
    }
}
