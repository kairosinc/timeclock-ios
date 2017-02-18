//
//  SetupViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 13/12/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    @IBOutlet weak var clientIDTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var siteIDTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    
    
    @IBAction func setupTouchUpInside(sender: AnyObject) {
        setup()
    }
    
    func setup() {
        guard
        let clientID = clientIDTextField.text where clientID.characters.count > 0,
        let siteID = siteIDTextField.text where siteID.characters.count > 0,
        let username = usernameTextField.text where username.characters.count > 0,
        let password = passwordTextField.text where password.characters.count > 0,
        let company = companyTextField.text where company.characters.count > 0
        else {
            let alert = UIAlertController(title: "Setup Failed", message: "Please check your credentials", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        WFMAPI.configure(clientID, siteID: siteID, username: username, password: password, company: company) { (error) in
            if let _ = error {
               let alert = UIAlertController(title: "Setup Failed", message: "Please check your credentials and internet connection", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                let _ = try? Keychain.delete(identifier: "client_id")
                WFMAPI.heimdallr()?.clearAccessToken()
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.kairosGrey()
    }

}

extension SetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        switch textField.tag {
            
        case 0:
            siteIDTextField.becomeFirstResponder()
        case 1:
            usernameTextField.becomeFirstResponder()
        case 2:
            passwordTextField.becomeFirstResponder()
        case 3:
            companyTextField.becomeFirstResponder()
        default:
            setup()
        }
        
        return true
    }
}
