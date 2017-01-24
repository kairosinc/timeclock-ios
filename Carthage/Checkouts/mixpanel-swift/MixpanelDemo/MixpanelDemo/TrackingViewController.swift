//
//  TrackingViewController.swift
//  MixpanelDemo
//
//  Created by Yarden Eitan on 7/15/16.
//  Copyright © 2016 Mixpanel. All rights reserved.
//

import UIKit
import Mixpanel

class TrackingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tableViewItems = ["Track w/o Properties",
                          "Track w Properties",
                          "Time Event 5secs",
                          "Clear Timed Events",
                          "Get Current SuperProperties",
                          "Clear SuperProperties",
                          "Register SuperProperties",
                          "Register SuperProperties Once",
                          "Register SP Once w Default Value",
                          "Unregister SuperProperty"]

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = tableViewItems[indexPath.item]
        cell.textLabel?.textColor = UIColor(red: 0.200000003, green: 0.200000003, blue: 0.200000003, alpha: 1)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let actionStr = tableViewItems[indexPath.item]
        var descStr = ""

        switch indexPath.item {
        case 0:
            let ev = "Track Event!"
            Mixpanel.mainInstance().track(event: ev)
            descStr = "Event: \"\(ev)\""
        case 1:
            let ev = "Track Event With Properties!"
            let p = ["Cool Property": "Property Value"]
            Mixpanel.mainInstance().track(event: ev, properties: p)
            descStr = "Event: \"\(ev)\"\n Properties: \(p)"
        case 2:
            let ev = "Timed Event"
            Mixpanel.mainInstance().time(event: ev)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                Mixpanel.mainInstance().track(event: ev)
            }
            descStr = "Timed Event: \"\(ev)\""
        case 3:
            Mixpanel.mainInstance().clearTimedEvents()
            descStr = "Timed Events Cleared"
        case 4:
            descStr = "Super Properties:\n"
            descStr += "\(Mixpanel.mainInstance().currentSuperProperties())"
        case 5:
            Mixpanel.mainInstance().clearSuperProperties()
            descStr = "Cleared Super Properties"
        case 6:
            let p = ["Super Property 1": 1,
                     "Super Property 2": "p2",
                     "Super Property 3": NSDate(),
                     "Super Property 4": ["a":"b"],
                     "Super Property 5": [3, "a", NSDate()],
                     "Super Property 6":
                        NSURL(string: "https://mixpanel.com")!,
                     "Super Property 7": NSNull()]
            Mixpanel.mainInstance().registerSuperProperties(p)
            descStr = "Properties: \(p)"
        case 7:
            let p = ["Super Property 1": 2.3]
            Mixpanel.mainInstance().registerSuperPropertiesOnce(p)
            descStr = "Properties: \(p)"
        case 8:
            let p = ["Super Property 1": 1.2]
            Mixpanel.mainInstance().registerSuperPropertiesOnce(p, defaultValue: 2.3)
            descStr = "Properties: \(p) with Default Value: 2.3"
        case 9:
            let p = "Super Property 2"
            Mixpanel.mainInstance().unregisterSuperProperty(p)
            descStr = "Properties: \(p)"
        default:
            break
        }

        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ActionCompleteViewController") as! ActionCompleteViewController
        vc.actionStr = actionStr
        vc.descStr = descStr
        vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        vc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }

}
