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
}

extension WFMService: TargetType {
    
    public var baseURL: NSURL { return NSURL(string: "https://kairos.com/api")! }
    
    public var path: String {
        switch self {
        case .Login(_, _):
            return "/users/sessions/"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .Login:
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
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .Login(_ , _):
            return stubbedResponse("LoginResponse")
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


