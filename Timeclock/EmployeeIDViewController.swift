//
//  EmployeeIDViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 06/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol EmployeeIDDelegate {
    func idEntered(punchData: PunchData?)
    func cancelled()
}

class EmployeeIDViewController: UIViewController {
    
    //MARK: Properties
    var delegate: EmployeeIDDelegate?
    var containerView: UIView?
    var punchData: PunchData?
    
    var appState: TimeClockFlowController.AppState? {
        didSet {
            guard let appState = appState else { return }
            configureForAppState(appState)
            setOpacityForAppState(appState)
        }
    }
    
    let primaryFont: UIFont = {
        return UIFont.boldSystemFontOfSize(44)
    }()
    
    let secondaryFont: UIFont = {
        return UIFont.boldSystemFontOfSize(30)
    }()
    
    //MARK: IBOutlet
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.textColor = UIColor.whiteColor()
            errorLabel.font = secondaryFont
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.font = primaryFont
        }
    }
    
    @IBOutlet weak var employeeIDLabel: UILabel! {
        didSet {
            employeeIDLabel.backgroundColor = UIColor.whiteColor()
            employeeIDLabel.textColor = UIColor.kairosDarkGrey()
            employeeIDLabel.font = primaryFont
        }
    }
    
    @IBOutlet weak var confirmButton: UIButton! {
        didSet {
            confirmButton.backgroundColor = UIColor.kairosGreen()
            confirmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            confirmButton.titleLabel?.font = primaryFont
        }
    }
    
    @IBOutlet weak var topMessageBackgroundView: UIView! {
        didSet {
            topMessageBackgroundView.backgroundColor = UIColor.kairosGrey()
        }
    }
    
    @IBOutlet var numPadButtons: [UIButton]! {
        didSet {
            for button in numPadButtons {
                button.backgroundColor = UIColor.kairosGrey()
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
                if button.tag >= 0 {
                    button.titleLabel?.font = primaryFont
                } else {
                    button.titleLabel?.font = secondaryFont
                }
            }
        }
    }
    
    @IBAction func backspaceLongPress(sender: AnyObject) {
        employeeIDLabel.text = ""
        dismissError()
    }
    
    
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: IBAction
    @IBAction func numPadTouchUpInside(sender: AnyObject) {
        guard let tag = sender.tag else { return }
        numberEntered(tag)
        dismissError()
    }
    
    @IBAction func backspaceTouchUpInside(sender: AnyObject) {
        removeLastCharacter()
        dismissError()
    }
    
    @IBAction func confirmTouchUpInside(sender: AnyObject) {
        guard let employeeID = employeeIDLabel.text else { return }
        DataController.sharedController?.fetchEmployee(employeeID, completion: { (managedObject, error) in
            
            let galleryName: String
            if
                let configuration = Configuration.fromUserDefaults(),
                let gallery = configuration.galleryID {
                galleryName = gallery
            } else {
                galleryName = "employees"
            }
            
            if let employee = managedObject as? Employee {
                if let
                    appState = self.appState,
                    punchData = self.punchData,
                    image = punchData.image
                    where appState == .EmployeeIDEnrolment || appState == .EmployeeIDVerification {
                        KairosSDK.enrollWithImage(image, subjectId: employeeID, galleryName: galleryName, success: nil, failure: nil)
                }
                
                self.punchData?.employee = employee
                self.delegate?.idEntered(self.punchData)
                
            } else {
                self.showError("Badge Number Not Found")
            }
        })
    }
    
    @IBAction func cancelTouchUpInside(sender: AnyObject) {
        delegate?.cancelled()
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.kairosDarkGrey()
    }
    
    //MARK: Methods
    func configureForAppState(appState: TimeClockFlowController.AppState) {
        titleLabel.text = "Enter Badge Number"
        employeeIDLabel.text = ""
        errorLabel.hidden = true
    }
    
    func numberEntered(number: Int) {
        let existingText: String
        if let existingUnwrappedValue = employeeIDLabel.text {
            existingText = existingUnwrappedValue
        } else {
            existingText = ""
        }
        
        employeeIDLabel.text = existingText + String(number)
    }
    
    func removeLastCharacter() {
        guard let currentValue = employeeIDLabel.text else { return }
        let newValue = currentValue.characters.dropLast()
        employeeIDLabel.text = String(newValue)
    }
    
    func showError(message: String) {
        errorLabel.text = message
        
        UIView.animateWithDuration(0.3) {
            self.topMessageBackgroundView.backgroundColor = UIColor.kairosRed()
            self.errorLabel.hidden = false
        }
    }
    
    func dismissError() {
        guard !errorLabel.hidden else { return }
        
        UIView.animateWithDuration(0.3) {
            self.topMessageBackgroundView.backgroundColor = UIColor.kairosGrey()
            self.errorLabel.hidden = true
        }
    }
}

extension EmployeeIDViewController: TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat {
        switch state {
        case .EmployeeIDVerification, .EmployeeIDEnrolment:
            return 1
        default:
            return 0
        }
    }
}
