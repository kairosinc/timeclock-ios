//
//  CaptureViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol CaptureDelegate {
    func imageCaptured(_ punchData: PunchData?)
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
        
        let galleryName: String
        if
            let configuration = Configuration.fromUserDefaults(),
            let gallery = configuration.galleryID {
            galleryName = gallery
        } else {
            galleryName = "employees"
        }
        

        KairosSDK.imageCaptureRecognize(withThreshold: "0.75",
                                                     galleryName: galleryName,
                                                     success: { (response:[AnyHashable: Any]!, image: UIImage!) in
                                                        
             if let imagesResponse = response["images"] as? NSArray {
                print(imagesResponse)
                let firstImagesResponse = imagesResponse.firstObject as? NSDictionary
                let transaction = firstImagesResponse?["transaction"]
                if let transaction = transaction as? [AnyHashable: Any] {
                    let confidence = transaction["confidence"] as? Float
                    self.punchData?.confidence = confidence
                    let subject_id = transaction["subject_id"] as? String
                    self.punchData?.subjectID = subject_id
                }
                                                        
            
                self.punchData?.image = image
                self.capturedImage(self.punchData)
             } else {
                
                self.punchData?.image = image
                self.capturedImage(self.punchData)
            }
            
            }, failure: { (response:[AnyHashable: Any]!, image: UIImage!) in
                print("failure \(response)")
                self.punchData?.image = image
                self.capturedImage(self.punchData)
        })
    }
    
    func capturedImage(_ punchData: PunchData?) {
        delegate?.imageCaptured(self.punchData)
    }
}

extension CaptureViewController: TimeClockViewController {
    func opacityForAppState(_ state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .idle, .capturing, .displayingOptions:
            return 1
        default:
            return 0
        }
    }
}
