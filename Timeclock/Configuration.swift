//
//  Configuration.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 15/12/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

class Configuration: NSObject, NSCoding {
    let enable2FA: Bool
    let enableFacialRecognition: Bool
    let punchUploadURL: String
    let employeeWebURL: String?
    let employeeDownloadURL: String
    
    init?(json: JSONType) {
        guard let clientConfig = json["client_config"] as? JSONType else { return nil }
        
        guard let enable2FA = clientConfig["enable_2fa"] as? NSNumber else { return nil }
        self.enable2FA = enable2FA.boolValue
        
        guard let enableFacialRecognition = clientConfig["enable_facial_recognition"] as? NSNumber else { return nil }
        self.enableFacialRecognition = enableFacialRecognition.boolValue
        
        guard let punchUploadURL = clientConfig["punch_upload_url"] as? String else { return nil }
        self.punchUploadURL = punchUploadURL
        
        guard let employeeDownloadURL = clientConfig["employee_download_url"] as? String else { return nil }
        self.employeeDownloadURL = employeeDownloadURL
        
        if let employeeWebURL = clientConfig["employee_web_url"] as? String {
            self.employeeWebURL = employeeWebURL
        } else {
            self.employeeWebURL = nil
        }
    }
    
    init(enable2FA: Bool, enableFacialRecognition: Bool, punchUploadURL: String, employeeWebURL: String?, employeeDownloadURL: String) {
        self.enable2FA = enable2FA
        self.enableFacialRecognition = enableFacialRecognition
        self.punchUploadURL = punchUploadURL
        self.employeeWebURL = employeeWebURL
        self.employeeDownloadURL = employeeDownloadURL
    }
    
    //MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        guard
            let enable2FA = decoder.decodeObjectForKey("enable2FA") as? Bool,
            let enableFacialRecognition = decoder.decodeObjectForKey("enableFacialRecognition") as? Bool,
            let punchUploadURL = decoder.decodeObjectForKey("punchUploadURL") as? String,
            let employeeDownloadURL = decoder.decodeObjectForKey("employeeDownloadURL") as? String
        else {
            return nil
        }
        
        let employeeWebURL = decoder.decodeObjectForKey("employeeWebURL") as? String
        
        self.init(
            enable2FA: enable2FA,
            enableFacialRecognition: enableFacialRecognition,
            punchUploadURL: punchUploadURL,
            employeeWebURL: employeeWebURL,
            employeeDownloadURL: employeeDownloadURL
        )
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.enable2FA, forKey: "enable2FA")
        coder.encodeObject(self.enableFacialRecognition, forKey: "enableFacialRecognition")
        coder.encodeObject(self.punchUploadURL, forKey: "punchUploadURL")
        coder.encodeObject(self.employeeDownloadURL, forKey: "employeeDownloadURL")
        
        if let employeeWebURL = self.employeeWebURL {
            coder.encodeObject(employeeWebURL, forKey: "employeeWebURL")
        }
    }
    
    func persist() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        defaults.setObject(data, forKey: "configuration")
        defaults.synchronize()
    }
    
    static func fromUserDefaults() -> Configuration? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard
            let data = defaults.objectForKey("configuration") as? NSData,
            let configuration = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Configuration
        else {
            return nil
        }

        return configuration
    }
    
    static func removeFromUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("configuration")
        defaults.synchronize()
    }
}
