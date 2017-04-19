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
    var dateTimeLabelTimer: Timer?
    var containerView: UIView?
    
    var appState: TimeClockFlowController.AppState? {
        didSet {
            guard let appState = appState else { return }
            setOpacityForAppState(appState)
        }
    }
    
    var punchData: PunchData?
    
    //MARK: IBOutlet
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tapToStartView: UIView! {
        didSet {
            tapToStartView.backgroundColor = UIColor.kairosDarkGrey()
        }
    }
    
    //MARK: IBAction
    @IBAction func tapGestureRecognizerAction(_ sender: AnyObject) {
        delegate?.dismiss()
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.kairosGrey()
        
        dateTimeLabelTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                                    target: self,
                                                                    selector: #selector(updateDateTimeLabels),
                                                                    userInfo: nil,
                                                                    repeats: true)
        
    }
    
    //MARK: Methods
    func updateDateTimeLabels() {
        let locale = Locale(identifier: "en_US_POSIX")
        let date = Date()
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.dateFormat = "h:mm a"
        timeLabel.text = timeFormatter.string(from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateLabel.text = dateFormatter.string(from: date)
    }
}

extension IdleViewController: TimeClockViewController {
    func opacityForAppState(_ state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .idle:
            return 1
        default:
            return 0
        }
    }
}
