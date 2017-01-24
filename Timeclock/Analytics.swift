//
//  Analytics.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 14/07/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation

struct Analytics {
    
    static func initializeServices(launchOptions: [NSObject: AnyObject]?) {
        for service in Analytics.services {
            service.initialize(launchOptions)
            if NSProcessInfo.processInfo().lowPowerModeEnabled {
                service.pauseUpload()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            NSProcessInfoPowerStateDidChangeNotification,
            object: nil,
            queue: nil,
            usingBlock: { _ in
                Analytics.updateLowPowerState()
        })
    }
    
    private static func updateLowPowerState() {
        if NSProcessInfo.processInfo().lowPowerModeEnabled {
            for service in Analytics.services {
                service.pauseUpload()
            }
        }
    }
    
    static func trackPushNotifiction(userInfo: [NSObject : AnyObject]) {
        for service in Analytics.services {
            service.trackPushNotifiction(userInfo)
        }
    }
    
    static let services = [MixpanelService.self]
    
    static func registerUserProperties(properties: AnalyticsProperties) {
        for service in services {
            service.registerUserProperties(properties)
        }
    }
    
    static func registerPushToken(pushToken: NSData) {
        for service in Analytics.services {
            service.registerPushToken(pushToken)
        }
    }
    
    static func aliasUser(alias: String) {
        for service in Analytics.services {
            service.aliasUser(alias)
        }
    }
    
    static func identifyUser(id: String) {
        for service in Analytics.services {
            service.identifyUser(id)
        }
    }
    
    static func trackEvent(event: AnalyticsEvent) {
        for service in Analytics.services {
            service.trackEvent(event)
        }
    }
    
    static func trackScreenView(name: String, properties: AnalyticsProperties?) {
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
