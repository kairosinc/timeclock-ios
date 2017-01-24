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
    static func trackEvent(event: AnalyticsEvent)
    static func registerUserProperties(properties: AnalyticsProperties)
    static func registerPushToken(pushToken: NSData)
    static func pauseUpload()
    static func resumeUpload()
    static func aliasUser(alias: String)
    static func identifyUser(id: String)
    static func initialize(launchOptions: [NSObject : AnyObject]?)
    static func trackPushNotifiction(userInfo: [NSObject : AnyObject])
    static func resetUserIdentifier()
}
