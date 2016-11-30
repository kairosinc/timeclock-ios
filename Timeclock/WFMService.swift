//
//  WFMService.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 05/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Moya

public enum WFMService {
    case Login(email: String, password: String)
    case Employees()
}

extension WFMService: TargetType {
    
    private static func standardParameters() -> JSONType {
        let deviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString
        let deviceModel = UIDevice.currentDevice().model
        let iosVersion = UIDevice.currentDevice().systemVersion
        let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        let latitude = LocationMonitor.sharedMonitor.locationManager.location?.coordinate.latitude
        let longitude = LocationMonitor.sharedMonitor.locationManager.location?.coordinate.longitude
        let locationAccuracy = LocationMonitor.sharedMonitor.locationManager.location?.horizontalAccuracy
        
        return [
            "device_id": deviceID ?? "",
            "device_model": deviceModel,
            "ios_version": iosVersion,
            "app_version": appVersion ?? "",
            "app_build": buildNumber ?? "",
            "latitude": latitude ?? "",
            "longitude": longitude ?? "",
            "location_accuracy": locationAccuracy ?? ""
        ]
    }
    
    public var baseURL: NSURL { return NSURL(string: "http://planneddev.timeclockdynamics.com:9100")! }
    
    public var path: String {
        switch self {
        case .Login(_, _):
            return "/users/sessions/"
        case .Employees():
            return "/EmployeeDownload/v1.0/Employees/download"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .Login, .Employees:
            return .POST
        }
    }
    
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
        case .Employees():
            return WFMService.standardParameters()
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .Login(_ , _):
            return stubbedResponse("LoginResponse")
            
        case .Employees():
            return stubbedResponse("employeesResponse")
        }
    }
    
    public var multipartBody: [Moya.MultipartFormData]? {
        return nil
    }
}

// MARK: - Helpers
private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

private extension WFMService {
    // MARK: - Provider support
    func stubbedResponse(filename: String) -> NSData! {
        @objc class TestClass: NSObject { }
        
        let bundle = NSBundle(forClass: TestClass.self)
        let path = bundle.pathForResource(filename, ofType: "json")
        return NSData(contentsOfFile: path!)
    }
}


