//
//  CaptureViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol CaptureDelegate {
    func imageCaptured(punchData: PunchData?)
    func timedOut()
}

class CaptureViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var capturedImageView: UIImageView!
    
    //MARK: Properties
    var delegate: CaptureDelegate?
    var containerView: UIView?
    
    var appState: TimeClockFlowController.AppState? {
        didSet {
            guard let appState = appState else { return }
            setOpacityForAppState(appState)
        }
    }
    
    var punchData: PunchData?
    
    //MARK: Methods
    func startCapturing() {
        
        /*
         KairosSDK.imageCaptureEnrollWithSubjectId("0000", galleryName: "employees", success: { (response:[NSObject : AnyObject]!, image: UIImage!) in
         print("success enroll \(response)")
         }) { (response:[NSObject : AnyObject]!, image: UIImage!) in
         print("failed to enrol: \(response)")
         }
 */

        
        
        KairosSDK.imageCaptureRecognizeWithThreshold("0.75",
                                                     galleryName: "employees",
                                                     success: { (response:[NSObject : AnyObject]!, image: UIImage!) in
                                                        
            let imagesResponse = response["images"]! as? NSArray
            print(imagesResponse)
            let firstImagesResponse = imagesResponse?.firstObject
            let trans = firstImagesResponse?["transaction"]
            if let trans = trans as? [NSObject: AnyObject] {
                let confidence = trans["confidence"] as? Float
                self.punchData?.confidence = confidence
                let subject_id = trans["subject_id"] as? String
                self.punchData?.subjectID = subject_id
            }
                                                        
            
            self.punchData?.image = image
            self.capturedImage(self.punchData)

            
            }, failure: { (response:[NSObject : AnyObject]!, image: UIImage!) in
                print("failire \(response)")
                self.punchData?.image = image
                self.capturedImage(self.punchData)
        })
    }
    
    func capturedImage(punchData: PunchData?) {
        delegate?.imageCaptured(self.punchData)
    }
}

extension CaptureViewController: TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .Idle, .Capturing, .DisplayingOptions:
            return 1
        default:
            return 0
        }
    }
}
