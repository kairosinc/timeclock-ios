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
    
    @IBAction func setupTouchUpInside(sender: AnyObject) {
        setup()
    }
    
    func setup() {
        guard let clientID = clientIDTextField.text where clientID.characters.count > 0 else { return }
        WFMAPI.configure(clientID) { (error) in
            if let _ = error {
               let alert = UIAlertController(title: "Setup Failed", message: "Please check your Client ID and internet connection", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                let _ = try? Keychain.delete(identifier: "client_id")
                WFMAPI.heimdallr.clearAccessToken()
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
        setup()
        textField.resignFirstResponder()
        return true
    }
}
