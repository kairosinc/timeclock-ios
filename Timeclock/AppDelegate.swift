//
//  AppDelegate.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 15/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Fabric
import Crashlytics
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var flowController: TimeClockFlowController?
    var syncTimer: NSTimer?
    let syncIntervalMins: Double = 20
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        guard
            let keysURL = NSBundle.mainBundle().URLForResource("Keys", withExtension: "plist"),
            let keys = NSDictionary(contentsOfURL: keysURL),
            let appID = keys["AppID"] as? String,
            let appKey = keys["AppKey"] as? String
            else {
                assertionFailure()
                return false
        }


        //Initialize the Kairos SDK
        KairosSDK.initWithAppId(appID, appKey: appKey)
        KairosSDK.setEnableFlash(true)
        KairosSDK.setEnableShutterSound(false)
        KairosSDK.setPreferredCameraType(UInt(KairosCameraFront))
        KairosSDK.setEnableCropping(false)
        
        
        syncTimer = NSTimer.scheduledTimerWithTimeInterval(
            (syncIntervalMins * 60),
            target: self,
            selector: #selector(sync),
            userInfo: nil,
            repeats: true)
        
        sync()
        
        return true
    }
    
    func sync() {
        WFMAPI.employees() { (employees, error) in }
        
        DataController.sharedController?.fetchPunches(completion: { (punches, error) in
            guard let punches = punches where !punches.isEmpty else { return }
            WFMAPI.punches(punches, completion: { (error) in
                if let _ = error {
                } else {
                    DataController.sharedController?.deletePunches(punches, completion: { (error) in })
                }
            })
        })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return parseLaunchURL(url)
    }
    
    func parseLaunchURL(url: NSURL) -> Bool {
        guard let clientID = url.host else { return false }
        WFMAPI.configure(clientID) { (error) in
            if let error = error {
                self.flowController?.setupFailed()
                print(error)
            } else {
                //Finish setup
                self.flowController?.setupComplete()
            }
        }
        return true
    }

}

