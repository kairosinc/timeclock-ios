//
//  ClockViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 22/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

class ClockViewController: UIViewController {

    //MARK: Properties
    var timeLabelTimer: NSTimer?
    
    //MARK: IBOutlet
    @IBOutlet weak var timeLabel: UILabel!
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.kairosDarkGrey()
        
        timeLabelTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                                                                target: self,
                                                                selector: #selector(updateTimeLabel),
                                                                userInfo: nil,
                                                                repeats: true)
    }
    
    //MARK: Methods
    func updateTimeLabel() {
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = NSDate()
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = locale
        timeFormatter.dateFormat = "h:mm a"
        timeLabel.text = timeFormatter.stringFromDate(date)
    }
}
