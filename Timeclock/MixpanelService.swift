//
//  MixpanelService.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 14/07/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Mixpanel

struct MixpanelService: AnalyticsService {
    
    static fileprivate var mixpanel: MixpanelInstance?
    
    static var apiToken: String = "d927bb999cd47d9b19dcc3ed156964eb"
    static var uploadInterval: Double = 60
    
    static func initialize(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        if let launchOptions = launchOptions {
            Mixpanel.initialize(token: MixpanelService.apiToken, launchOptions: launchOptions)
            MixpanelService.mixpanel = Mixpanel.mainInstance()
        } else {
            Mixpanel.initialize(token: MixpanelService.apiToken)
        }
        
        MixpanelService.mixpanel = Mixpanel.mainInstance()
        
        
        if let mixpanel = MixpanelService.mixpanel {
            mixpanel.flushInterval = uploadInterval
            mixpanel.flushOnBackground = true
        }
    }
    
    static func trackPushNotifiction(_ userInfo: [AnyHashable: Any]) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.trackPushNotification(userInfo)
    }
    
    static func trackEvent(_ event: AnalyticsEvent) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        
        if let properties = event.properties {
            mixpanel.track(event: event.name, properties: properties)
        } else {
            mixpanel.track(event: event.name)
        }
    }
    
    static func registerUserProperties(_ properties: AnalyticsProperties) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.people.set(properties: properties)
    }
    
    static func registerPushToken(_ pushToken: Data) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.people.addPushDeviceToken(pushToken)
    }
    
    static func aliasUser(_ alias: String) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.createAlias(alias, distinctId: mixpanel.distinctId)
        mixpanel.identify(distinctId: mixpanel.distinctId)
        MixpanelService.registerUserProperties(["$email": alias])
    }
    
    static func identifyUser(_ id: String) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.identify(distinctId: id)
        MixpanelService.registerUserProperties(["$email": id])
    }
    
    static func resumeUpload() {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.flush()
        mixpanel.flushInterval = uploadInterval
    }
    
    static func pauseUpload() {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.flushInterval = 0
    }
    
    static func resetUserIdentifier() {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.reset()
    }
}

