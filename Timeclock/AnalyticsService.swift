//
//  AnalyticsService.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 14/07/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

protocol AnalyticsService {
    static var apiToken: String { get }
    static var uploadInterval: Double { get set }
    static func trackEvent(_ event: AnalyticsEvent)
    static func registerUserProperties(_ properties: AnalyticsProperties)
    static func registerPushToken(_ pushToken: Data)
    static func pauseUpload()
    static func resumeUpload()
    static func aliasUser(_ alias: String)
    static func identifyUser(_ id: String)
    static func initialize(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    static func trackPushNotifiction(_ userInfo: [AnyHashable: Any])
    static func resetUserIdentifier()
}
