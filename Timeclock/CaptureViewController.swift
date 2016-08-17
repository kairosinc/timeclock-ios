//
//  CaptureViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol CaptureDelegate {
    func imageCaptured(image: UIImage)
    func timedOut()
}

class CaptureViewController: UIViewController {
    
    //MARK: Properties
    var delegate: CaptureDelegate?
    
    //MARK: App State
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .Idle:
            break
        case .Capturing:
            break
        case .ProcessingImage:
            break
        case .DisplayingOptions:
            break
        }
    }
}
