//
//  AnalyticsEvent.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 14/07/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Mixpanel

typealias AnalyticsProperties = [String: MixpanelType]

struct AnalyticsEvent {
    let name: String
    let properties: AnalyticsProperties?
}
