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
        case Idle, Capturing, ProcessingImage, DisplayingOptions, EmployeeID
    }
    
    var configuration: Configuration? {
        didSet {
            guard let configuration = configuration else { return }
            configuration.clockOptionsViewController.delegate = self
            configuration.idleViewController.delegate = self
            configuration.captureViewController.delegate = self
            
            setUIState(.Idle)
        }
    }
    
    struct Configuration {
        let clockOptionsViewController: ClockOptionsViewController
        let idleViewController: IdleViewController
        let captureViewController: CaptureViewController
        
        var viewControllers: [TimeClockViewController] {
            return [
                clockOptionsViewController,
                idleViewController,
                captureViewController
            ]
        }
    }
    
    func setUIState(state: AppState) {
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut], animations: {
            guard let configuration = self.configuration else { return }
            for timeClockViewController in configuration.viewControllers {
                guard let vc = timeClockViewController as? UIViewController else { break }
                vc.view.alpha = timeClockViewController.opacityForAppState(state)
            }
        }, completion: nil)
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
        configuration?.captureViewController.startCapturing()
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
