//
//  Analytics.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 14/07/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

struct Analytics {
    
    static func initializeServices(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        for service in Analytics.services {
            service.initialize(launchOptions)
            if ProcessInfo.processInfo.isLowPowerModeEnabled {
                service.pauseUpload()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: nil,
            using: { _ in
                Analytics.updateLowPowerState()
        })
    }
    
    fileprivate static func updateLowPowerState() {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            for service in Analytics.services {
                service.pauseUpload()
            }
        }
    }
    
    static func trackPushNotifiction(_ userInfo: [AnyHashable: Any]) {
        for service in Analytics.services {
            service.trackPushNotifiction(userInfo)
        }
    }
    
    static let services = [MixpanelService.self]
    
    static func registerUserProperties(_ properties: AnalyticsProperties) {
        for service in services {
            service.registerUserProperties(properties)
        }
    }
    
    static func registerPushToken(_ pushToken: Data) {
        for service in Analytics.services {
            service.registerPushToken(pushToken)
        }
    }
    
    static func aliasUser(_ alias: String) {
        for service in Analytics.services {
            service.aliasUser(alias)
        }
    }
    
    static func identifyUser(_ id: String) {
        for service in Analytics.services {
            service.identifyUser(id)
        }
    }
    
    static func trackEvent(_ event: AnalyticsEvent) {
        for service in Analytics.services {
            service.trackEvent(event)
        }
    }
    
    static func trackScreenView(_ name: String, properties: AnalyticsProperties?) {
        let eventName = "Screen Viewed: \(name)"
        let event = AnalyticsEvent(name: eventName, properties: properties)
        
        for service in Analytics.services {
            service.trackEvent(event)
        }
    }
    
    static func resetUserIdentifier() {
        for service in Analytics.services {
            service.resetUserIdentifier()
        }
    }
}
