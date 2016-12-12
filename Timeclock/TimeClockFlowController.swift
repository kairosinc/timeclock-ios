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
        case Idle
        case Capturing
        case ProcessingImage
        case DisplayingOptions(employee: Employee)
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
}

extension TimeClockFlowController: ClockOptionsDelegate {
    func clock(option: ClockOptions) {
        setUIState(.Idle)
    }
}

extension TimeClockFlowController: IdleDelegate {
    func dismiss() {
        
//        DataController.sharedController?.fetchEmployee("1110342", contextType: DataController.ContextType.Main, completion: { (managedObject, error) in
//            guard let managedObject = managedObject as? Employee else { return }
//            self.configuration?.clockOptionsViewController.employee = managedObject
//            self.setUIState(.DisplayingOptions(employee: managedObject))
//        })

        
        setUIState(.Capturing)
        configuration?.captureViewController.startCapturing()
    }
}

extension TimeClockFlowController: CaptureDelegate {
    func imageCaptured(image: UIImage, employeeID: String?) {
        print("image captured")
        configuration?.employeeIDViewController
        if let employeeID = employeeID {
            setUIState(.EmployeeIDVerification(employeeID: employeeID))
        } else {
            setUIState(.EmployeeIDEnrolment(image: image))
        }
        
        self.configuration?.employeeIDViewController.image = image
    }
    
    func timedOut() {
        
    }
}

extension TimeClockFlowController: EmployeeIDDelegate {
    func idEntered(employee: Employee, image: UIImage?) {
        setUIState(.DisplayingOptions(employee: employee))
        self.configuration?.clockOptionsViewController.employee = employee
        self.configuration?.clockOptionsViewController.image = image

    }
    
    func cancelled() {
        setUIState(.Idle)
    }
}
