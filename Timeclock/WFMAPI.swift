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
import enum Result.Result

public typealias JSONType = [String : Any]

public struct WFMAPI {
    
    //OAuth
    public static let tokenURL = URL(string: "http://config.timeclockdynamics.com:9100/sign_in/v1.0/auth/token")!
    
    fileprivate static let oAuthClientSecret = "3e691351c44346d589ca626b5c28415c"
    
    fileprivate static let oAuthStore = OAuthAccessTokenKeychainStore(service: "com.kairos.timeclock.keychain.oauth")
    fileprivate static let configOAuthStore = OAuthAccessTokenKeychainStore(service: "com.kairos.timeclock.keychain.configoauth")

    fileprivate static let oAuthclientCredentials = OAuthClientCredentials(
        id: Configuration.fromUserDefaults()?.clientID ?? "",
        secret: WFMAPI.oAuthClientSecret
    )
    
    fileprivate static let configOAuthclientCredentials = OAuthClientCredentials(
        id: WFMAPI.configClientID()?.clientID ?? "",
        secret: WFMAPI.oAuthClientSecret
    )
    
    public static let configHeimdallr = Heimdallr(
        tokenURL: tokenURL,
        accessTokenStore: WFMAPI.configOAuthStore,
        accessTokenParser: WFMOAuthAccessTokenParser(),
        httpClient: WFMOAuthHTTPClientNSURLSession(oAuthClientCredentials: WFMAPI.configOAuthclientCredentials),
        resourceRequestAuthenticator: HeimdallResourceRequestAuthenticatorForm()
    )
    
    fileprivate static func authURL() -> String {
        return Configuration.fromUserDefaults()?.authURL ?? ""
    }
    
    public static func heimdallr() -> Heimdallr? {
        guard let url = URL(string: WFMAPI.authURL()) else { return nil }
        
        return Heimdallr(
            tokenURL: url,
            accessTokenStore: WFMAPI.oAuthStore,
            accessTokenParser: WFMOAuthAccessTokenParser(),
            httpClient: WFMOAuthHTTPClientNSURLSession(oAuthClientCredentials: WFMAPI.oAuthclientCredentials),
            resourceRequestAuthenticator: HeimdallResourceRequestAuthenticatorForm())
    }
    
    static let manager = Manager(
        configuration: URLSessionConfiguration.default
    )
    
    static let defaultProvider = MoyaProvider<WFMService>(
        endpointClosure: WFMAPI.endpointClosure,
        requestClosure: WFMAPI.requestClosure,
        manager: manager
    )
    
    fileprivate static let accessToken = "tbc"
    
    fileprivate static let endpointClosure = { (target: WFMService) -> Endpoint<WFMService> in
        let url = URL(string: target.path)!.absoluteString
        let endpoint: Endpoint<WFMService> = Endpoint<WFMService>(url: url,
                                                                      sampleResponseClosure: {
                                                                        .networkResponse(200, target.sampleData)
                                                                        },
                                                                      method: target.method,
                                                                      parameters: target.parameters)
        
        return endpoint
    }
    
    static func configClientID() -> (clientID: String, siteID: String, username: String, password: String, company: String)? {
        guard
            let clientIDData = try? Keychain.get(identifier: "config_client_id"),
            let siteIDData = try? Keychain.get(identifier: "config_site_id"),
            let usernameData = try? Keychain.get(identifier: "config_username"),
            let passwordData = try? Keychain.get(identifier: "config_password"),
            let companyData = try? Keychain.get(identifier: "config_company"),
            let clientID = NSKeyedUnarchiver.unarchiveObject(with: clientIDData) as? String,
            let siteID = NSKeyedUnarchiver.unarchiveObject(with: siteIDData) as? String,
            let username = NSKeyedUnarchiver.unarchiveObject(with: usernameData) as? String,
            let password = NSKeyedUnarchiver.unarchiveObject(with: passwordData) as? String,
            let company = NSKeyedUnarchiver.unarchiveObject(with: companyData) as? String
        else {
            return nil
        }
        
        return (clientID, siteID, username, password, company)
    }
    
    fileprivate static let requestClosure = { (endpoint: Endpoint<WFMService>, done: @escaping MoyaProvider.RequestResultClosure) in
        guard var request = endpoint.urlRequest else { return }
        
        let heimdallrForRequest: Heimdallr?
        let username: String
        let password: String
        let clientIDString: String
        let siteIDString: String
        let companyString: String
        
        
        if
            let url = request.url?.absoluteString,
            url == WFMService.configure().path {
            heimdallrForRequest = configHeimdallr
            
            guard let config = WFMAPI.configClientID() else {
                return
            }
            
            clientIDString = config.clientID
            username = config.username
            password = config.password
            siteIDString = config.siteID
            companyString = config.company

        } else {
            heimdallrForRequest = WFMAPI.heimdallr()
            
            guard
                let savedUsername = Configuration.fromUserDefaults()?.username,
                let savedPassword = Configuration.fromUserDefaults()?.password,
                let savedClientIDString = Configuration.fromUserDefaults()?.clientID,
                let savedAuthURL = Configuration.fromUserDefaults()?.authURL
            else { return }
            
            username = savedUsername
            password = savedPassword
            clientIDString = savedClientIDString
            siteIDString = WFMAPI.configClientID()?.siteID ?? ""
            companyString = Configuration.fromUserDefaults()?.company ?? ""
        }
        
        heimdallrForRequest?.authenticateRequest(request) { result in
            switch result {
            case .success(let authenticatedRequest):
                done(.success(authenticatedRequest))
            case .failure(let error):
                print("authenticateRequest failure: \(error.localizedDescription)")
                print("requesting access token due to authenticateRequest failure")
                
                heimdallrForRequest?.requestAccessToken(grantType: "password", parameters: [
                    "username": username,
                    "password": password,
                    "client_id": clientIDString,
                    "site_id": siteIDString,
                    "company": companyString
                ]) { result in
                    switch result {
                    case .success(let authenticatedRequest):
                        heimdallrForRequest?.authenticateRequest(request) { result in
                            switch result {
                            case .success(let authenticatedRequest):
                                print("requestAccessToken success")
                                done(.success(authenticatedRequest))
                            case .failure(let error):
                                print("requestAccessToken failure A: \(error.localizedDescription)")
                                done(.failure(MoyaError.underlying(error)))
                            }
                        }
                    case .failure(let error):
                        print("requestAccessToken failure B: \(error.localizedDescription)")
                        done(.failure(MoyaError.underlying(error)))
                    }
                }
            }
        }
    }
    
    public static func configure(
        _ clientID: String,
        siteID: String,
        username: String,
        password: String,
        company: String,
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        configureCompletion: @escaping (_ error: KairosAPIError?) -> Void) -> Cancellable {
        
        //Save clientID to keychain
        let clientIDData = NSKeyedArchiver.archivedData(withRootObject: clientID)
        let siteIDData = NSKeyedArchiver.archivedData(withRootObject: siteID)
        let usernameData = NSKeyedArchiver.archivedData(withRootObject: username)
        let passwordData = NSKeyedArchiver.archivedData(withRootObject: password)
        let companyData = NSKeyedArchiver.archivedData(withRootObject: company)
        
        do {
            try Keychain.set(identifier: "config_client_id", data: clientIDData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
            try Keychain.set(identifier: "config_site_id", data: siteIDData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
            try Keychain.set(identifier: "config_username", data: usernameData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
            try Keychain.set(identifier: "config_password", data: passwordData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
            try Keychain.set(identifier: "config_company", data: companyData, accessibility: String(kSecAttrAccessibleWhenUnlocked))
        } catch {
            configureCompletion(KairosAPIError.unknown())
            print("could not save to keychain, fail here")
        }
        
        return WFMAPI.getConfig(siteID: siteID) { (configuration, error) in
            if let configuration = configuration {
                configuration.persist()
                DataController.sharedController?.syncScheduler.syncInterval = configuration.syncInterval
                configureCompletion(nil)
            } else if let error = error {
                print("could not complete API request, fail here: \(error)")
                configureCompletion(error)
            } else {
                print("unknown error")
                configureCompletion(KairosAPIError.unknown())
            }
        }
    }
    
    public static func employees(
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        completion: @escaping (_ employees: [Employee]?, _ error: KairosAPIError?) -> Void) {
        
        WFMAPI.request(provider, target: WFMService.employees()) { (result) in
            switch result {
            case let .success(response):
                print(response)
                guard
                    let json = try? response.mapJSON() as? JSONType,
                    let unwrappedJSON = json,
                    let employeesDictionary = unwrappedJSON["employees"] as? [JSONType]
                else {
                    completion(nil, nil)
                    return
                }
                DataController.sharedController!.persistEmployees(employeesDictionary, completion: { (managedObject, error) in
                    completion(nil, nil)
                })
                
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    public static func punches(
        _ punches: [Punch],
        provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        completion: @escaping (_ error: KairosAPIError?) -> Void) -> Cancellable {
        
        return WFMAPI.request(provider, target: WFMService.punches(punches: punches)) { (result) in
            switch result {
            case let .success(response):
                print(response)
                completion(nil)
                
            case let .failure(error):
                print(error)
                completion(error)
            }
        }
    }
    
    fileprivate static func getConfig(
        _ provider: MoyaProvider<WFMService> = WFMAPI.defaultProvider,
        siteID: String,
        completion: @escaping (_ configuration: Configuration?, _ error: KairosAPIError?) -> Void) -> Cancellable {
        
        return WFMAPI.request(provider, target: WFMService.configure()) { (result) in
            switch result {
            case let .success(response):
                
                guard
                    let json = try? response.mapJSON() as? JSONType,
                    let unwrappedJSON = json
                    else {
                    completion(nil, nil)
                    return
                }

                let configuration = Configuration(json: unwrappedJSON)
                print(response)
                completion(configuration, nil)
                
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func logError(_ response: Moya.Response?) {
        
        
        var properties: AnalyticsProperties = [:]
        if let response = response {
            properties["statusCode"] = response.statusCode
            properties["description"] = response.description
            
            if let nsResponse = response.response, let url = nsResponse.url {
                properties["url"] = url
            }
        }
        
        let event = AnalyticsEvent(name: "apiError", properties: properties)
        
        Analytics.trackEvent(event)

    }
    
    fileprivate static func request(
        _ provider: MoyaProvider<WFMService>,
        target: WFMService,
        completion: @escaping (_ result: Result<Moya.Response, KairosAPIError>) -> ()) -> Cancellable {
        return provider.request(target) { (result) in
            
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    //parse out errors
                    guard response.statusCode >= 200 && response.statusCode <= 299 else {
                        print(response)
                        if let serverError = KairosAPIError.fromJSONData(response.data) {
                            completion(.failure(serverError))
                            
                        } else {
                            let error = KairosAPIError.unknown()
                            WFMAPI.logError(response)
                            completion(.failure(error))
                        }
                        
                        break
                    }
                    completion(.success(response))
                    
                case let .failure(error):
                    WFMAPI.logError(error.response)
                    switch error {
                    case .imageMapping(_), .jsonMapping(_), .stringMapping(_), .statusCode(_), .requestMapping(_):
                        let apiError = KairosAPIError.unknown()
                        completion(.failure(apiError))
                        
                    case .underlying(let swiftError):
                        let errorMessage = swiftError.localizedDescription
                        let apiError = KairosAPIError.known(errorMessage)
                        completion(.failure(apiError))
                    }
                }
            }
        }
    }
}

