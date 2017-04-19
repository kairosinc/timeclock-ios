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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        guard
            let keysURL = Bundle.main.url(forResource: "Keys", withExtension: "plist"),
            let keys = NSDictionary(contentsOf: keysURL),
            let appID = keys["AppID"] as? String,
            let appKey = keys["AppKey"] as? String
            else {
                assertionFailure()
                return false
        }
        
        //Initializa Analytics
        Analytics.initializeServices(launchOptions)


        //Initialize the Kairos SDK
        KairosSDK.initWithAppId(appID, appKey: appKey)
        KairosSDK.setEnableFlash(true)
        KairosSDK.setEnableShutterSound(false)
        KairosSDK.setPreferredCameraType(UInt(KairosCameraFront))
        KairosSDK.setEnableCropping(false)
        
        if
            let config = Configuration.fromUserDefaults(),
            let interval = config.syncInterval {
            
            DataController.sharedController?.syncScheduler.syncInterval = interval
            DataController.sharedController?.syncScheduler.sync()
        }
        
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        DataController.sharedController?.syncScheduler.sync()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return parseLaunchURL(url)
    }
    
    func parseLaunchURL(_ url: URL) -> Bool {
        
        guard
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let clientID = queryItems.filter({$0.name == "clientid"}).first?.value,
            let siteID = queryItems.filter({$0.name == "siteid"}).first?.value,
            let username =  queryItems.filter({$0.name == "username"}).first?.value,
            let password = queryItems.filter({$0.name == "password"}).first?.value,
            let company = queryItems.filter({$0.name == "company"}).first?.value
        else { return false }
        
        let configure = WFMAPI.configure(clientID, siteID: siteID, username: username, password: password, company: company) { (error) in
            if let error = error {
                self.flowController?.setupFailed()
                print(error)
            } else {
                //Finish setup
                WFMAPI.employees(completion: { (employees: [Employee]?, error: KairosAPIError?) in
                    if let _ = error {
                        Configuration.removeFromUserDefaults()
                    } else {
                        print("success, finish setup!!")
                        self.flowController?.setupComplete()
                    }
                })
                
            }
        }
        return true
    }

}

