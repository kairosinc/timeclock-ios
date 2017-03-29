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
    case employees()
    case punches(punches: [Punch])
    case configure()
}

extension WFMService: TargetType {

    public var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        default:
            return .request
        }
    }

    
    fileprivate static func standardParameters() -> JSONType {
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        let deviceModel = UIDevice.current.model
        let iosVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let latitude = LocationMonitor.sharedMonitor.locationManager.location?.coordinate.latitude
        let longitude = LocationMonitor.sharedMonitor.locationManager.location?.coordinate.longitude
        let locationAccuracy = LocationMonitor.sharedMonitor.locationManager.location?.horizontalAccuracy
        let siteID = WFMAPI.configClientID()?.siteID
        let company = WFMAPI.configClientID()?.company
        
        return [
            "device_id": deviceID ?? "",
            "device_model": deviceModel,
            "ios_version": iosVersion,
            "app_version": appVersion ?? "",
            "app_build": buildNumber ?? "",
            "latitude": latitude ?? "",
            "longitude": longitude ?? "",
            "location_accuracy": locationAccuracy ?? "",
            "site_id": siteID ?? "",
            "company": company ?? "",
        ]
    }
    
    
    public var baseURL: URL { return URL(string: "http://kairos.com")! }
    
    public var path: String {
        switch self {
        case .employees():
            guard let employeeDownloadURL = Configuration.fromUserDefaults()?.employeeDownloadURL else { return "/" }
            return employeeDownloadURL
        case .punches(_):
            guard let configuration = Configuration.fromUserDefaults() else { return "/" }
            return configuration.punchUploadURL
        case .configure():
            return "http://config.timeclockdynamics.com:9100/get_config/v1.0/client/get_config"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .employees, .punches, .configure:
            return .post
        }
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case .employees():
            return WFMService.standardParameters()
            
        case .punches(let punches):
            do {
                let punchesJSON = try JSONSerialization.data(withJSONObject: punches.jsonArray(), options: [])
                var params = WFMService.standardParameters()
                params["punches"] = String(data: punchesJSON, encoding: String.Encoding.utf8)!
                return params
            } catch {
                return nil
            }
            
        default:
            return WFMService.standardParameters()
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .employees():
            return stubbedResponse("employeesResponse")
            
        case .punches(_):
            return stubbedResponse("employeesResponse")
            
        case .configure():
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
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
    var UTF8EncodedData: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}

private extension WFMService {
    // MARK: - Provider support
    func stubbedResponse(_ filename: String) -> Data! {
        @objc class TestClass: NSObject { }
        
        let bundle = Bundle(for: TestClass.self)
        let path = bundle.path(forResource: filename, ofType: "json")
        return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
    }
}

private extension Collection where Iterator.Element: JSONable {
    
    func jsonArray() -> [JSONType] {
        return map { (element: JSONable) -> JSONType in
            return element.jsonValue
        }
    }
}


