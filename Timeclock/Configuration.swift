//
//  Configuration.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 15/12/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

final class Configuration: NSObject, NSCoding {
    let enable2FA: Bool
    let enableFacialRecognition: Bool
    let punchUploadURL: String
    let employeeWebURL: String?
    let employeeDownloadURL: String
    let authURL: String
    let galleryID: String?
    let syncInterval: Double?
    let password: String
    let username: String
    let clientID: String
    let company: String?
    
    init?(json: JSONType) {
        guard let clientConfig = json["client_config"] as? JSONType else { return nil }
        guard let auth = clientConfig["auth"] as? JSONType else { return nil }
        
        guard let enable2FA = clientConfig["enable_2fa"] as? NSNumber else { return nil }
        self.enable2FA = enable2FA.boolValue
        
        guard let enableFacialRecognition = clientConfig["enable_facial_recognition"] as? NSNumber else { return nil }
        self.enableFacialRecognition = enableFacialRecognition.boolValue

        guard let punchUploadURL = clientConfig["punch_upload_url"] as? String else { return nil }
        self.punchUploadURL = punchUploadURL
        
        guard let employeeDownloadURL = clientConfig["employee_download_url"] as? String else { return nil }
        self.employeeDownloadURL = employeeDownloadURL
        
        guard let authURL = clientConfig["auth_url"] as? String else { return nil }
        self.authURL = authURL
        
        guard let password = auth["password"] as? String else { return nil }
        self.password = password
        
        guard let username = auth["username"] as? String else { return nil }
        self.username = username
        
        guard let clientID = auth["clientid"] as? String else { return nil }
        self.clientID = clientID
        
        if let employeeWebURL = clientConfig["employee_web_url"] as? String {
            self.employeeWebURL = employeeWebURL
        } else {
            self.employeeWebURL = nil
        }
        
        if let galleryID = clientConfig["gallery_id"] as? String {
            self.galleryID = galleryID
        } else {
            self.galleryID = nil
        }
        
        if let syncInterval = clientConfig["sync_interval"] as? Double {
            self.syncInterval = syncInterval
        } else {
            self.syncInterval = nil
        }
        
        if let company = auth["company"] as? String {
            self.company = company
        } else {
            self.company = nil
        }
    }
    
    init(
        enable2FA: Bool,
        enableFacialRecognition: Bool,
        punchUploadURL: String,
        employeeWebURL: String?,
        employeeDownloadURL: String,
        authURL: String,
        galleryID: String?,
        syncInterval: Double?,
        password: String,
        username: String,
        clientID: String,
        company: String?) {
        
        self.enable2FA = enable2FA
        self.enableFacialRecognition = enableFacialRecognition
        self.punchUploadURL = punchUploadURL
        self.employeeWebURL = employeeWebURL
        self.employeeDownloadURL = employeeDownloadURL
        self.authURL = authURL
        self.galleryID = galleryID
        self.syncInterval = syncInterval
        self.password = password
        self.username = username
        self.clientID = clientID
        self.company = company
    }
    
    //MARK: NSCoding
    convenience init?(coder aDecoder: NSCoder) {
        let enable2FA = aDecoder.decodeBool(forKey: "enable2FA")
        let enableFacialRecognition = aDecoder.decodeBool(forKey: "enableFacialRecognition")
        
        guard
            let punchUploadURL = aDecoder.decodeObject(forKey: "punchUploadURL") as? String,
            let employeeDownloadURL = aDecoder.decodeObject(forKey: "employeeDownloadURL") as? String,
            let authURL = aDecoder.decodeObject(forKey: "authURL") as? String,
            let password = aDecoder.decodeObject(forKey: "password") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String,
            let clientID = aDecoder.decodeObject(forKey: "clientID") as? String
        else {
            return nil
        }
        
        let employeeWebURL = aDecoder.decodeObject(forKey: "employeeWebURL") as? String
        let galleryID = aDecoder.decodeObject(forKey: "galleryID") as? String
        let syncInterval = aDecoder.decodeDouble(forKey: "syncInterval")
        let company = aDecoder.decodeObject(forKey: "company") as? String
        
        self.init(
            enable2FA: enable2FA,
            enableFacialRecognition: enableFacialRecognition,
            punchUploadURL: punchUploadURL,
            employeeWebURL: employeeWebURL,
            employeeDownloadURL: employeeDownloadURL,
            authURL: authURL,
            galleryID: galleryID,
            syncInterval: syncInterval,
            password: password,
            username: username,
            clientID: clientID,
            company: company
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.enable2FA, forKey: "enable2FA")
        aCoder.encode(self.enableFacialRecognition, forKey: "enableFacialRecognition")
        aCoder.encode(self.enableFacialRecognition, forKey: "enableFacialRecognition")
        aCoder.encode(self.punchUploadURL, forKey: "punchUploadURL")
        aCoder.encode(self.employeeDownloadURL, forKey: "employeeDownloadURL")
        aCoder.encode(self.authURL, forKey: "authURL")
        aCoder.encode(self.password, forKey: "password")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.clientID, forKey: "clientID")
        
        if let employeeWebURL = self.employeeWebURL {
            aCoder.encode(employeeWebURL, forKey: "employeeWebURL")
        }
        
        if let galleryID = self.galleryID {
            aCoder.encode(galleryID, forKey: "galleryID")
        }
        
        if let syncInterval = self.syncInterval {
            aCoder.encode(syncInterval, forKey: "syncInterval")
        }
        
        if let company = self.company {
            aCoder.encode(company, forKey: "company")
        }
    }
    
    func persist() {
        let defaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        defaults.set(data, forKey: "configuration")
        defaults.synchronize()
    }
    
    static func fromUserDefaults() -> Configuration? {
        let defaults = UserDefaults.standard
        
        guard
            let data = defaults.data(forKey: "configuration"),
            let obj = NSKeyedUnarchiver.unarchiveObject(with: data)
        else {
            return nil
        }

        if let configuration = obj as? Configuration {
            return configuration
        } else {
            return nil
        }
    }
    
    static func removeFromUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "configuration")
        defaults.synchronize()
    }
}
