//
//  ClockOptionsViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 16/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

enum ClockOptions: Int {
    case `in` = 0
    case out = 1
    case breakStart = 2
    case breakEnd = 3
    
    var stringValue: String {
        switch self {
        case .in:
            return "in"
        case .out:
            return "out"
        case .breakStart:
            return "mealout"
        case .breakEnd:
            return "mealin"
        }
    }
}

protocol ClockOptionsDelegate {
    func clock(_ option: ClockOptions)
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
                let deviceID = UIDevice.current.identifierForVendor,
                let url = URL(string: (baseURL + "/?badge_number=" + badgeNumber + "&device_id=" + deviceID.uuidString))
            else {
                webView.isHidden = true
                return
            }
            
            let request = URLRequest(url: url)
            webView.loadRequest(request)
            webView.isHidden = false
            
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
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: date)
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
        return UIFont.boldSystemFont(ofSize: 70)
    }()
    
    let secondaryFont: UIFont = {
        return UIFont.boldSystemFont(ofSize: 40)
    }()
    
    let tertiaryFont: UIFont = {
        return UIFont.boldSystemFont(ofSize: 34)
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
            greetingLabel.textColor = UIColor.white
            greetingLabel.text = ""
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = primaryFont
            nameLabel.textColor = UIColor.white
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
            inButton.setTitleColor(UIColor.white, for: UIControlState())
        }
    }
    
    @IBOutlet var outButton: UIButton! {
        didSet {
            outButton.backgroundColor = UIColor.kairosBlue()
            outButton.setTitleColor(UIColor.white, for: UIControlState())

        }
    }
    
    @IBOutlet var breakStartButton: UIButton! {
        didSet {
            breakStartButton.backgroundColor = UIColor.white
            breakStartButton.setTitleColor(UIColor.kairosGreen(), for: UIControlState())
        }
    }
    
    @IBOutlet var breakEndButton: UIButton! {
        didSet {
            breakEndButton.backgroundColor = UIColor.white
            breakEndButton.setTitleColor(UIColor.kairosBlue(), for: UIControlState())
        }
    }
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.titleLabel?.font = tertiaryFont
            doneButton.backgroundColor = UIColor.kairosRed()
            doneButton.setTitleColor(UIColor.white, for: UIControlState())
        }
    }
    
    @IBOutlet weak var debugBadgeLabel: UILabel!
    @IBOutlet weak var debugSubjectIDLabel: UILabel!
    @IBOutlet weak var debugConfidenceLabel: UILabel!
    
    
    //MARK: IBAction
    @IBAction func doneTouchUpInside(_ sender: AnyObject) {
        punchData = nil
        delegate?.cancel()
    }
    
    @IBAction func clockOptionTouchUpInside(_ sender: AnyObject) {
        guard
            let tag = sender.tag,
            let selectedOption = ClockOptions(rawValue: tag)
        else {
            return
        }
        
        let punchDate = Date()
        
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        utcDateFormatter.timeZone = TimeZone(identifier: "UTC")
        let timestampUTC = utcDateFormatter.string(from: punchDate)
        
        let localDateFormatter = DateFormatter()
        localDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        localDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        localDateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let timestampLocal = localDateFormatter.string(from: punchDate)
        
        let clockOffset: Int16 = 0 //Investigate
        
        let currentTimeZone = TimeZone.autoupdatingCurrent
        let timeZoneOffsetSeconds = currentTimeZone.secondsFromGMT(for: punchDate)
        let timezoneOffset = (timeZoneOffsetSeconds / 60) / 60
        
        let timezoneName = NSTimeZone.local.abbreviation()
        let timezoneDST = NSTimeZone.local.isDaylightSavingTime().intValue()
        
        let badgeNumber = punchData?.employee?.badgeNumber
        
        let badgeNumberValid = true
        
        let direction = selectedOption.stringValue
        
        
        let online: String
        if let onlineBool = DataController.sharedController?.syncScheduler.reachability?.isReachable {
            online = String(onlineBool)
        } else {
            online = "true"
        }
        
        let facerecTransactionID: String? = nil
        
        let facerecImageType: String?
        let facerecImageData: String?
        
        if let image = punchData?.image, let imageData = UIImageJPEGRepresentation(image, 0.7) {
            facerecImageType = "image/jpeg"
            facerecImageData = imageData.base64EncodedString(options: .lineLength64Characters)
        } else {
            facerecImageType = ""
            facerecImageData = ""
        }

        let confidenceNSNumber: NSNumber?
        if let confidence = punchData?.confidence {
            confidenceNSNumber = NSNumber(value: confidence)
        } else {
            confidenceNSNumber = nil
        }
        
        DataController.sharedController?.createAndPersistPunch(
            timestampUTC,
            timestampLocal: timestampLocal,
            clockOffset: clockOffset,
            timezoneOffset: Int16(timezoneOffset),
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
            confidence: confidenceNSNumber
        )
        
        
        delegate?.clock(selectedOption)
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        view.backgroundColor = UIColor.kairosGrey()
    }
}

extension ClockOptionsViewController: TimeClockViewController {
    func opacityForAppState(_ state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .displayingOptions:
            return 1
        default:
            return 0
        }
    }
}

extension Bool: IntValue {
    func intValue() -> Int {
        if self {
            return 1
        }
        return 0
    }
}

protocol IntValue {
    func intValue() -> Int
}
