//
//  ClockOptionsViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

enum ClockOptions: Int {
    case In = 0
    case Out = 1
    case BreakStart = 2
    case BreakEnd = 3
}

protocol ClockOptionsDelegate {
    func clock(option: ClockOptions)
}

class ClockOptionsViewController: UIViewController {
    
    //MARK: Properties
    var employee: Employee? {
        didSet {
            guard let employee = employee else { return }
            greetingLabel.text = "Hello"
            nameLabel.text = employee.firstName
        }
    }
    var delegate: ClockOptionsDelegate?
    var containerView: UIView?
    
    var appState: TimeClockFlowController.AppState? {
        didSet {
            guard let appState = appState else { return }
            setOpacityForAppState(appState)
        }
    }
    
    let primaryFont: UIFont = {
        return UIFont.boldSystemFontOfSize(70)
    }()
    
    let secondaryFont: UIFont = {
        return UIFont.boldSystemFontOfSize(40)
    }()
    
    let tertiaryFont: UIFont = {
        return UIFont.boldSystemFontOfSize(34)
    }()
    
    //MARK: IBOutlet
    @IBOutlet weak var topMessageBackgroundView: UIView! {
        didSet {
            topMessageBackgroundView.backgroundColor = UIColor.kairosGreen()
        }
    }
    
    @IBOutlet weak var greetingLabel: UILabel! {
        didSet {
            greetingLabel.font = tertiaryFont
            greetingLabel.textColor = UIColor.whiteColor()
            greetingLabel.text = "Good Evening"
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = primaryFont
            nameLabel.textColor = UIColor.whiteColor()
            nameLabel.text = "Tom"
        }
    }
    
    @IBOutlet var clockOptionButtons: [UIButton]! {
        didSet {
            for button in clockOptionButtons {
                button.titleLabel?.font = tertiaryFont
            }
        }
    }
    
    @IBOutlet var inButton: UIButton! {
        didSet {
            inButton.backgroundColor = UIColor.kairosGreen()
            inButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
    }
    
    @IBOutlet var outButton: UIButton! {
        didSet {
            outButton.backgroundColor = UIColor.kairosBlue()
            outButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)

        }
    }
    
    @IBOutlet var breakStartButton: UIButton! {
        didSet {
            breakStartButton.backgroundColor = UIColor.whiteColor()
            breakStartButton.setTitleColor(UIColor.kairosGreen(), forState: .Normal)
        }
    }
    
    @IBOutlet var breakEndButton: UIButton! {
        didSet {
            breakEndButton.backgroundColor = UIColor.whiteColor()
            breakEndButton.setTitleColor(UIColor.kairosBlue(), forState: .Normal)
        }
    }
    
    @IBOutlet weak var webView: UIWebView! {
        didSet {
            guard let url = NSURL(string: "http://planneddev.timeclockdynamics.com/hrnow/") else { return }
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    
    //MARK: IBAction
    @IBAction func clockOptionTouchUpInside(sender: AnyObject) {
        guard let
            tag = sender.tag,
            selectedOption = ClockOptions(rawValue: tag)
        else {
            return
        }
        
        delegate?.clock(selectedOption)
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        view.backgroundColor = UIColor.kairosGrey()
    }
}

extension ClockOptionsViewController: TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .DisplayingOptions:
            return 1
        default:
            return 0
        }
    }
}
