//
//  TimeClockViewController.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 17/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import UIKit

protocol TimeClockViewController {
    func opacityForAppState(_ state: TimeClockFlowController.AppState) -> CGFloat
    var containerView: UIView? {get set}
    var appState: TimeClockFlowController.AppState? {get set}
    var punchData: PunchData? {get set}
}

extension TimeClockViewController {
    func setOpacityForAppState(_ appState: TimeClockFlowController.AppState) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            guard let vc = self as? UIViewController else { return }
            vc.view.alpha = self.opacityForAppState(appState)
            
        }, completion: { (finished: Bool) in
            guard let vc = self as? UIViewController else { return }
            self.containerView?.isHidden = (vc.view.alpha == 0)
            self.containerView?.isUserInteractionEnabled = !(vc.view.alpha == 0)
        })
    }
}
