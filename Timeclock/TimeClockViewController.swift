//
//  TimeClockViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 17/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol TimeClockViewController {
    func opacityForAppState(state: TimeClockFlowController.AppState) -> CGFloat
    var containerView: UIView? {get set}
}
