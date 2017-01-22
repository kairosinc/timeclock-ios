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
    
    var stringValue: String {
        switch self {
        case .In:
            return "in"
        case .Out:
            return "out"
        case .BreakStart:
            return "mealout"
        case .BreakEnd:
            return "mealin"
        }
    }
}

protocol ClockOptionsDelegate {
    func clock(option: ClockOptions)
    func cancel()
}

class ClockOptionsViewController: UIViewController {
    
    //MARK: Properties
    var punchData: PunchData? {
        didSet {
            guard let employee = punchData?.employee else { return }
            greetingLabel.text = greetingForTimeOfDay()
            nameLabel.text = employee.firstName
            
            guard
                let badgeNumber = employee.badgeNumber,
                let configuration = Configuration.fromUserDefaults(),
                let baseURL = configuration.employeeWebURL,
                let deviceID = UIDevice.currentDevice().identifierForVendor,
                let url = NSURL(string: (baseURL + "/?badge_number=" + badgeNumber + "&device_id=" + deviceID.UUIDString))
            else {
                webView.hidden = true
                return
            }
            
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
            webView.hidden = false
            
            //Debug
            debugBadgeLabel.text = "badge_number:" + badgeNumber
            if let subjectID = punchData?.subjectID {
                debugSubjectIDLabel.text = "subject_id:" + subjectID
            } else {
                debugSubjectIDLabel.text = "subject_id:"
            }
            
            if let confidence = punchData?.confidence {
                debugConfidenceLabel.text = "confidence:" + String(confidence)
            } else {
                debugConfidenceLabel.text = "confidence:"
            }
        }
    }
    
    func greetingForTimeOfDay() -> String {
        let date = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.stringFromDate(date)
        guard let hourInt = Int(hourString) else { return "Hello" }
        
        if hourInt < 12 {
            return "Good Morning"
        } else if hourInt >= 12 && hourInt < 18 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
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
            greetingLabel.text = ""
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = primaryFont
            nameLabel.textColor = UIColor.whiteColor()
            nameLabel.text = ""
        }
    }
    
    @IBOutlet var clockOptionButtons: [UIButton]! {
        didSet {
            for button in clockOptionButtons {
                button.titleLabel?.font = tertiaryFont
                button.titleLabel?.adjustsFontSizeToFitWidth = true
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
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.titleLabel?.font = tertiaryFont
            doneButton.backgroundColor = UIColor.kairosRed()
            doneButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
    }
    
    @IBOutlet weak var debugBadgeLabel: UILabel!
    @IBOutlet weak var debugSubjectIDLabel: UILabel!
    @IBOutlet weak var debugConfidenceLabel: UILabel!
    
    
    //MARK: IBAction
    @IBAction func doneTouchUpInside(sender: AnyObject) {
        punchData = nil
        delegate?.cancel()
    }
    
    @IBAction func clockOptionTouchUpInside(sender: AnyObject) {
        guard let
            tag = sender.tag,
            selectedOption = ClockOptions(rawValue: tag)
        else {
            return
        }
        
        let punchDate = NSDate()
        
        let utcDateFormatter = NSDateFormatter()
        utcDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        utcDateFormatter.timeZone = NSTimeZone(name: "UTC")
        let timestampUTC = utcDateFormatter.stringFromDate(punchDate)
        
        let localDateFormatter = NSDateFormatter()
        localDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        localDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        localDateFormatter.timeZone = NSTimeZone.localTimeZone()
        let timestampLocal = localDateFormatter.stringFromDate(punchDate)
        
        let clockOffset: Int16 = 0 //Investigate
        
        let timezoneOffsetDateFormatter = NSDateFormatter()
        timezoneOffsetDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        timezoneOffsetDateFormatter.dateFormat = "Z"
        timezoneOffsetDateFormatter.timeZone = NSTimeZone.localTimeZone()
        let timezoneOffset = Int16(timezoneOffsetDateFormatter.stringFromDate(punchDate))
        
        let timezoneName = NSTimeZone.localTimeZone().abbreviation
        let timezoneDST = Int(NSTimeZone.localTimeZone().daylightSavingTime)
        
        let badgeNumber = punchData?.employee?.badgeNumber
        
        let badgeNumberValid = true
        
        let direction = selectedOption.stringValue
        
        
        let online: String
        if let onlineBool = DataController.sharedController?.syncScheduler.reachability?.isReachable() {
            online = String(onlineBool)
        } else {
            online = "true"
        }
        
        let facerecTransactionID: String? = nil
        
        let facerecImageType: String?
        let facerecImageData: String?
        
        if let image = punchData?.image, imageData = UIImageJPEGRepresentation(image, 0.7) {
            facerecImageType = "image/jpeg"
            facerecImageData = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        } else {
            facerecImageType = ""
            facerecImageData = ""
        }

        
        
        DataController.sharedController?.createAndPersistPunch(
            timestampUTC,
            timestampLocal: timestampLocal,
            clockOffset: clockOffset,
            timezoneOffset: timezoneOffset!,
            timezoneName: timezoneName!,
            timezoneDST: Int16(timezoneDST),
            badgeNumber: badgeNumber!,
            badgeNumberValid: badgeNumberValid,
            direction: direction,
            online: online,
            facerecTransactionID: facerecTransactionID,
            facerecImageType: facerecImageType,
            facerecImageData: facerecImageData,
            subjectID: punchData?.subjectID,
            confidence: punchData?.confidence
        )
        
        
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
