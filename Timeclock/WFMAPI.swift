//
//  WFMAPI.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 05/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Alamofire
import Foundation
import Moya

public typealias JSONType = [String : AnyObject]

public struct WFMAPI {
    
    static func certificates() -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        @objc class TestClass: NSObject { }
        let bundle = NSBundle(forClass: TestClass.self)
        
        let environmentIntermediateCertificateName = "TBC"
        
        let paths = [
            bundle.pathForResource(environmentIntermediateCertificateName, ofType: "cer")
        ]
        
        
        certificates = paths
            .filter({$0 != nil})
            .map({$0 as String!})
            .map { (path: String) -> NSData? in
                return NSData(contentsOfFile: path)
            }
            .filter({$0 != nil})
            .map({$0 as NSData!})
            .map { (certificateData: NSData) -> SecCertificate in
                return SecCertificateCreateWithData(nil, certificateData)!
        }
        
        return certificates
    }
    
    
    static let policies: [String: ServerTrustPolicy] = [
        "kairos.com": .PinCertificates(
            certificates: WFMAPI.certificates(),
            validateCertificateChain: true,
            validateHost: true
        )
    ]
    
    static let manager = Manager(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
    )
    
    static let defaultProvider = MoyaProvider<WFMService>(
        endpointClosure: WFMAPI.endpointClosure,
        manager: manager
    )
    
    private static let accessToken = "tbc"
    
    private static let endpointClosure = { (target: WFMService) -> Endpoint<WFMService> in
        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        let endpoint: Endpoint<WFMService> = Endpoint<WFMService>(URL: url,
                                                                      sampleResponseClosure: {
                                                                        .NetworkResponse(200, target.sampleData)
                                                                        },
                                                                      method: target.method,
                                                                      parameters: target.parameters)
        
        return endpoint.endpointByAddingParameters(["access_token": WFMAPI.accessToken])
        
    }
    
    //TODO: Replace response with user model once API is in place
    public static func login(
        provider: MoyaProvider<WFMService>,
        email: String,
        password: String,
        completion: (user: String?, error: Moya.Error?) -> Void) {
        
        let login = WFMService.Login(
            email: email,
            password: password
        )
        
        provider.request(login) { result in
            switch result {
            case let .Success(response):
                do {
                    guard let
                        json = try response.mapJSON() as? JSONType,
                        _ = json["user"] as? JSONType
                        else {
                            //Add parsing error type once model is in place
                            completion(user: nil, error: nil)
                            return
                    }
                    
                    //TODO: Replace with User Model once API is in place
                    let user = "someUser"
                    completion(user: user, error: nil)
                    
                } catch {
                    //Add parsing error type once model is in place
                    completion(user: nil, error: nil)
                }
                
            case let .Failure(error):
                error
                completion(user: nil, error: error)
            }
        }
        
    }
}

