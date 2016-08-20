//
//  IdleViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol IdleDelegate {
    func dismiss()
}

class IdleViewController: UIViewController {
    
    //MARK: Properties
    var delegate: IdleDelegate?
    var dateTimeLabelTimer: NSTimer?
    
    //MARK: IBOutlet
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    //MARK: IBAction
    @IBAction func tapGestureRecognizerAction(sender: AnyObject) {
        delegate?.dismiss()
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTimeLabelTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                                                                    target: self,
                                                                    selector: #selector(updateDateTimeLabels),
                                                                    userInfo: nil,
                                                                    repeats: true)
        
    }
    
    //MARK: Methods
    @objc func updateDateTimeLabels() {
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = NSDate()
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = locale
        timeFormatter.dateFormat = "H:mm a"
        timeLabel.text = timeFormatter.stringFromDate(date)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
}

extension IdleViewController: TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .Idle:
            return 1
        default:
            return 0
        }
    }
}
