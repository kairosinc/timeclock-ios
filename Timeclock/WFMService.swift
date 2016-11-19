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
        return [
            "device_id": "68753A44­4D6F­1226­9C60­0050E4C00067",
            "device_model": "iPad3,1",
            "ios_version": "6.1.3",
            "app_version": "4.0",
            "app_build": "107",
            "latitude": 51.50341761532306,
            "longitude": 0.12040704488754272,
            "location_accuracy": 12.5663706143592
        ]
    }
    
    public var baseURL: NSURL { return NSURL(string: "https://kairos.com/api")! }
    
    public var path: String {
        switch self {
        case .Login(_, _):
            return "/users/sessions/"
        case .Employees():
            return "/employees/download"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .Login:
            return .POST
        case .Employees:
            return .GET
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


