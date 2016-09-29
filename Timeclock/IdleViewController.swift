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
    var containerView: UIView?
    
    var appState: TimeClockFlowController.AppState? {
        didSet {
            guard let appState = appState else { return }
            setOpacityForAppState(appState)
        }
    }
    
    //MARK: IBOutlet
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tapToStartView: UIView! {
        didSet {
            tapToStartView.backgroundColor = UIColor.kairosDarkGrey()
        }
    }
    
    //MARK: IBAction
    @IBAction func tapGestureRecognizerAction(sender: AnyObject) {
        delegate?.dismiss()
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.kairosGrey()
        
        dateTimeLabelTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                                                                    target: self,
                                                                    selector: #selector(updateDateTimeLabels),
                                                                    userInfo: nil,
                                                                    repeats: true)
        
    }
    
    //MARK: Methods
    func updateDateTimeLabels() {
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
