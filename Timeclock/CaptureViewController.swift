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
}

class CaptureViewController: UIViewController {
    
    //MARK: Properties
    var delegate: CaptureDelegate?
}
