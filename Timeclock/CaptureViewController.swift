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
        KairosSDK.imageCaptureRecognizeWithThreshold("0.75",
                                                     galleryName: "employees",
                                                     success: { (response:[NSObject : AnyObject]!, image: UIImage!) in
//            print("success detect \(response["images"])")
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
                                                        
            
//            print(trans)
            self.punchData?.image = image
            self.capturedImage(self.punchData)

            
            }, failure: { (response:[NSObject : AnyObject]!, image: UIImage!) in
                print("failire \(response)")
                self.punchData?.image = image
                self.capturedImage(self.punchData)
        })
        
        //1 Capture image and call recognize
        
        //2a If recognize is successfull, goto 3
        //2b If recognize is unsuccessfull, ask for employee ID and then goto 3
        
        //3 Show clock options,
        
        //4 Create new clock punch with selected option and ID
//        performSelector(#selector(capturedImage), withObject: nil, afterDelay: 3)
        
        /*
        KairosSDK.imageCaptureEnrollWithSubjectId("10024", galleryName: "employees", success: { (response:[NSObject : AnyObject]!, image: UIImage!) in
            print("success enroll \(response)")
            }) { (response:[NSObject : AnyObject]!, image: UIImage!) in
                print("failed to enrol: \(response)")
        }
 */
        
    }
    
    func capturedImage(punchData: PunchData?) {
//        let image = UIImage()
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
