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
    
    static private var mixpanel: MixpanelInstance?
    
    static var apiToken: String = ""
    static var uploadInterval: Double = 60
    
    static func initialize(launchOptions: [NSObject : AnyObject]?) {
        
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
    
    static func trackPushNotifiction(userInfo: [NSObject : AnyObject]) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.trackPushNotification(userInfo)
    }
    
    static func trackEvent(event: AnalyticsEvent) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        
        if let properties = event.properties {
            mixpanel.track(event: event.name, properties: properties)
        } else {
            mixpanel.track(event: event.name)
        }
    }
    
    static func registerUserProperties(properties: AnalyticsProperties) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.people.set(properties: properties)
    }
    
    static func registerPushToken(pushToken: NSData) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.people.addPushDeviceToken(pushToken)
    }
    
    static func aliasUser(alias: String) {
        guard let mixpanel = MixpanelService.mixpanel else { return }
        mixpanel.createAlias(alias, distinctId: mixpanel.distinctId)
        mixpanel.identify(distinctId: mixpanel.distinctId)
        MixpanelService.registerUserProperties(["$email": alias])
    }
    
    static func identifyUser(id: String) {
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
