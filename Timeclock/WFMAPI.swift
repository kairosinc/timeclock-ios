//
//  WFMAPI.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 05/09/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Alamofire
import Foundation
import Heimdallr
import Moya

public typealias JSONType = [String : AnyObject]

public struct WFMAPI {
    
    //OAuth
    public static let tokenURL = NSURL(string: "http://config.timeclockdynamics.com:9100/sign_in/v1.0/auth/token")!
    
    private static let oAuthClientSecret = "3e691351c44346d589ca626b5c28415c"
    
    private static let oAuthStore = OAuthAccessTokenKeychainStore(service: "com.kairos.timeclock.keychain.oauth")
    private static let configOAuthStore = OAuthAccessTokenKeychainStore(service: "com.kairos.timeclock.keychain.configoauth")

    private static let oAuthclientCredentials = OAuthClientCredentials(
        id: Configuration.fromUserDefaults()?.clientID ?? "",
        secret: WFMAPI.oAuthClientSecret
    )
    
    private static let configOAuthclientCredentials = OAuthClientCredentials(
        id: WFMAPI.configClientID()?.clientID ?? "",
        secret: WFMAPI.oAuthClientSecret
    )
    
    public static let heimdallr = Heimdallr(
        tokenURL: tokenURL,
        accessTokenStore: WFMAPI.oAuthStore,
        accessTokenParser: WFMOAuthAccessTokenParser(),
        httpClient: WFMOAuthHTTPClientNSURLSession(oAuthClientCredentials: WFMAPI.oAuthclientCredentials),
        resourceRequestAuthenticator: HeimdallResourceRequestAuthenticatorForm()
    )
    
    public static let configHeimdallr = Heimdallr(
        tokenURL: tokenURL,
        accessTokenStore: WFMAPI.configOAuthStore,
        accessTokenParser: WFMOAuthAccessTokenParser(),
        httpClient: WFMOAuthHTTPClientNSURLSession(oAuthClientCredentials: WFMAPI.configOAuthclientCredentials),
        resourceRequestAuthenticator: HeimdallResourceRequestAuthenticatorForm()
    )
    
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
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration()
//        serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
    )
    
    static let defaultProvider = MoyaProvider<WFMService>(
        endpointClosure: WFMAPI.endpointClosure,
        requestClosure: WFMAPI.requestClosure,
        manager: manager
    )
    
    private static let accessToken = "tbc"
    
    private static let endpointClosure = { (target: WFMService) -> Endpoint<WFMService> in
        let url = NSURL(string: target.path)!.absoluteString
        let endpoint: Endpoint<WFMService> = Endpoint<WFMService>(URL: url!,
                                                                      sampleResponseClosure: {
                                                                        .NetworkResponse(200, target.sampleData)
                                                                        },
                                                                      method: target.method,
                                                                      parameters: target.parameters)
        
        return endpoint
    }
    
    static func configClientID() -> (clientID: String, siteID: String, username: String, password: String)? {
        guard
            let clientIDData = try? Keychain.get(identifier: "config_client_id"),
            let siteIDData = try? Keychain.get(identifier: "config_site_id"),
            let usernameData = try? Keychain.get(identifier: "config_username"),
            let passwordData = try? Keychain.get(identifier: "config_password"),
            let clientID = NSKeyedUnarchiver.unarchiveObjectWithData(clientIDData) as? String,
            let siteID = NSKeyedUnarchiver.unarchiveObjectWithData(siteIDData) as? String,
            let username = NSKeyedUnarchiver.unarchiveObjectWithData(usernameData) as? String,
            let password = NSKeyedUnarchiver.unarchiveObjectWithData(passwordData) as? String
        else {
            return nil
        }
        
        return (clientID, siteID, username, password)
    }
    
    private static let requestClosure = { (endpoint: Endpoint<WFMService>, done: MoyaProvider.RequestResultClosure) in
        let request = endpoint.urlRequest
        
        let heimdallrForRequest: Heimdallr
        let username: String
        let password: String
        let clientIDString: String
        let siteIDString: String
        
        if let url = request.URL?.absoluteString
        where url == WFMService.Configure().path {
            heimdallrForRequest = configHeimdallr
            
            guard let config = WFMAPI.configClientID() else {
                return
            }
            
            clientIDString = config.clientID
            username = config.username
            password = config.password
            siteIDString = config.siteID

        } else {
            heimdallrForRequest = heimdallr
            
            guard let
                savedUsername = Configuration.fromUserDefaults()?.username,
                savedPassword = Configuration.fromUserDefaults()?.password,
                savedClientIDString = Configuration.fromUserDefaults()?.clientID
            else { return }
            
            username = savedUsername
            password = savedPassword
            clientIDString = savedClientIDString
            siteIDString = WFMAPI.configClientID()?.siteID ?? ""
        }
        
        heimdallrForRequest.authenticateRequest(request) { result in
            switch result {
            case .Success(let authenticatedRequest):
                done(.Success(authenticatedRequest))
            case .Failure(let error):
                print("failure: \(error.localizedDescription)")
                
                heimdallrForRequest.requestAccessToken(grantType: "password", parameters: [
                    "username": username,
                    "password": password,
                    "client_id": clientIDString,
                    "site_id": siteIDString
                ]) { result in
                    switch result {
                    case .Success(let authenticatedRequest):
                        heimdallr.authenticateRequest(request) { result in
                            switch result {
                            case .Success(let authenticatedRequest):
                                done(.Success(authenticatedRequest))
                            case .Failure(let error):
                                print("failure: \(error.localizedDescription)")
                                done(.Failure(Moya.Error.Underlying(error)))
                            }
                        }
                    case .Failure(let error):
                        print("failure: \(error.localizedDescription)")
                        done(.Failure(Moya.Error.Underlying(error)))
                    }
                }
            }
        }
    }
    
    public static func configure(
        clientID: String,
        siteID: String,
        username: String,
        password: String,
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        completion: (error: ErrorType?) -> Void) {
        
        //Save clientID to keychain
        let clientIDData = NSKeyedArchiver.archivedDataWithRootObject(clientID)
        let siteIDData = NSKeyedArchiver.archivedDataWithRootObject(siteID)
        let usernameData = NSKeyedArchiver.archivedDataWithRootObject(username)
        let passwordData = NSKeyedArchiver.archivedDataWithRootObject(password)
        
        do {
            try Keychain.set(identifier: "config_client_id", data: clientIDData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
            try Keychain.set(identifier: "config_site_id", data: siteIDData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
            try Keychain.set(identifier: "config_username", data: usernameData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
            try Keychain.set(identifier: "config_password", data: passwordData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
        } catch {
            completion(error: KairosAPIError.Unknown())
            print("could not save to keychain, fail here")
        }
        
        WFMAPI.getConfig(siteID: siteID) { (configuration, error) in
            if let configuration = configuration {
                configuration.persist()
                DataController.sharedController?.syncScheduler.syncInterval = configuration.syncInterval
                
                WFMAPI.employees(completion: { (employees, error) in
                    if let _ = error {
                        Configuration.removeFromUserDefaults()
                    }
                    print("success, finish setup!!")
                    completion(error: error)
                })
                
            } else if let error = error {
                print("could not complete API request, fail here: \(error)")
                completion(error: error)
            } else {
                print("unknown error")
                completion(error: KairosAPIError.Unknown())
            }
        }
    }
    
    public static func employees(
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        completion: (employees: [Employee]?, error: ErrorType?) -> Void) {
        
        WFMAPI.request(provider, target: WFMService.Employees()) { (result) in
            switch result {
            case let .Success(response):
                print(response)
                guard let
                    json = try? response.mapJSON() as? JSONType,
                    unwrappedJSON = json,
                    employeesDictionary = unwrappedJSON["employees"] as? [JSONType]
                    else {
                        //Add parsing error type once model is in place
                        completion(employees: nil, error: nil)
                        return
                }
                DataController.sharedController!.persistEmployees(employeesDictionary, completion: { (managedObject, error) in
                    completion(employees: nil, error: nil)
                })
                
            case let .Failure(error):
                print(error)
                completion(employees: nil, error: error)
            }
        }
    }
    
    public static func punches(
        punches: [Punch],
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        completion: (error: ErrorType?) -> Void) {
        
        WFMAPI.request(provider, target: WFMService.Punches(punches: punches)) { (result) in
            switch result {
            case let .Success(response):
                print(response)
                completion(error: nil)
                
            case let .Failure(error):
                print(error)
                completion(error: error)
            }
        }
    }
    
    private static func getConfig(
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        siteID: String,
        completion: (configuration: Configuration?, error: ErrorType?) -> Void) {
        
        WFMAPI.request(provider, target: WFMService.Configure()) { (result) in
            switch result {
            case let .Success(response):
                
                guard let
                    json = try? response.mapJSON() as? JSONType,
                    unwrappedJSON = json
                    else {
                        completion(configuration: nil, error: nil)
                        return
                }

                let configuration = Configuration(json: unwrappedJSON)
                print(response)
                completion(configuration: configuration, error: nil)
                
            case let .Failure(error):
                print(error)
                completion(configuration: nil, error: error)
            }
        }
    }
    
    private static func request(
        provider: MoyaProvider<WFMService>,
        target: WFMService,
        completion: (result: Result<Moya.Response, KairosAPIError>) -> ()) -> Cancellable {
        return provider.request(target) { (result) in
            
            dispatch_async(dispatch_get_main_queue(), {
                switch result {
                case let .Success(response):
                    //parse out errors
                    guard response.statusCode >= 200 && response.statusCode <= 299 else {
                        print(response)
                        if let serverError = KairosAPIError.fromJSONData(response.data) {
                            completion(result: .Failure(serverError))
                            
                        } else {
                            let error = KairosAPIError.Unknown()
                            completion(result: .Failure(error))
                        }
                        
                        break
                    }
                    completion(result: .Success(response))
                    
                case let .Failure(error):
                    //maybe reformat network errors before forwarding on?
                    switch error {
                    case .ImageMapping(_), .JSONMapping(_), .StringMapping(_), .StatusCode(_), .Data(_):
                        let apiError = KairosAPIError.Unknown()
                        completion(result: .Failure(apiError))
                        
                    case .Underlying(let nsError):
                        if let errorMessage = nsError.localizedFailureReason {
                            let apiError = KairosAPIError.Known(errorMessage)
                            completion(result: .Failure(apiError))
                        } else {
                            let apiError = KairosAPIError.Unknown()
                            completion(result: .Failure(apiError))
                        }
                    }
                }
            })
        }
    }
}

