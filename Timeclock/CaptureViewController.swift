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
    
    //MARK: Methods
    func startCapturing() {
        performSelector(#selector(capturedImage), withObject: nil, afterDelay: 3)
    }
    
    func capturedImage() {
        let image = UIImage()
        delegate?.imageCaptured(image)
    }
}

extension CaptureViewController: TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .Idle, .Capturing, .ProcessingImage, .DisplayingOptions:
            return 1
        }
    }
}
