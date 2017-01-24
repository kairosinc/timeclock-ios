//
//  MixpanelDemoTests.swift
//  MixpanelDemoTests
//
//  Created by Yarden Eitan on 6/5/16.
//  Copyright © 2016 Mixpanel. All rights reserved.
//

import XCTest
import Nocilla

@testable import Mixpanel
@testable import MixpanelDemo

class MixpanelDemoTests: MixpanelBaseTests {

    func test5XXResponse() {
        _ = stubTrack().andReturn(503)

        mixpanel.track(event: "Fake Event")

        mixpanel.flush()
        waitForSerialQueue()

        mixpanel.flush()
        waitForSerialQueue()

        // Failure count should be 3
        let waitTime =
            mixpanel.flushInstance.flushRequest.networkRequestsAllowedAfterTime - NSDate().timeIntervalSince1970
        print("Delta wait time is \(waitTime)")
        XCTAssert(waitTime >= 110, "Network backoff time is less than 2 minutes.")
        XCTAssert(mixpanel.flushInstance.flushRequest.networkConsecutiveFailures == 2,
                  "Network failures did not equal 2")
        XCTAssert(mixpanel.eventsQueue.count == 1,
                  "Removed an event from the queue that was not sent")
    }

    func testRetryAfterHTTPHeader() {
        _ = stubTrack().andReturn(200)?.withHeader("Retry-After", "60")

        mixpanel.track(event: "Fake Event")

        mixpanel.flush()
        waitForSerialQueue()

        mixpanel.flush()
        waitForSerialQueue()

        // Failure count should be 3
        let waitTime =
            mixpanel.flushInstance.flushRequest.networkRequestsAllowedAfterTime - NSDate().timeIntervalSince1970
        print("Delta wait time is \(waitTime)")
        XCTAssert(fabs(60 - waitTime) < 5, "Mixpanel did not respect 'Retry-After' HTTP header")
        XCTAssert(mixpanel.flushInstance.flushRequest.networkConsecutiveFailures == 0,
                  "Network failures did not equal 0")
    }

    func testFlushEvents() {
        stubTrack()

        mixpanel.identify(distinctId: "d1")
        for i in 0..<50 {
            mixpanel.track(event: "event \(i)")
        }

        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "events should have been flushed")

        for i in 0..<60 {
            mixpanel.track(event: "evemt \(i)")
        }

        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "events should have been flushed")
    }


    func testFlushPeople() {
        stubEngage()

        mixpanel.identify(distinctId: "d1")
        for i in 0..<50 {
            mixpanel.people.set(property: "p1", to: "\(i)")
        }

        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.people.peopleQueue.isEmpty, "people should have been flushed")
        for i in 0..<60 {
            mixpanel.people.set(property: "p1", to: "\(i)")
        }
        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.people.peopleQueue.isEmpty, "people should have been flushed")
    }

    func testFlushNetworkFailure() {
        stubTrack().andFailWithError(
            NSError(domain: "com.mixpanel.sdk.testing", code: 1, userInfo: nil))
        mixpanel.identify(distinctId: "d1")
        for i in 0..<50 {
            mixpanel.track(event: "event \(UInt(i))")
        }
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.count == 50, "50 events should be queued up")
        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.count == 50,
                      "events should still be in the queue if flush fails")
    }

    func testAddingEventsAfterFlush() {
        stubTrack()
        mixpanel.identify(distinctId: "d1")
        for i in 0..<10 {
            mixpanel.track(event: "event \(UInt(i))")
        }
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.count == 10, "10 events should be queued up")
        mixpanel.flush()
        for i in 0..<5 {
            mixpanel.track(event: "event \(UInt(i))")
        }
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.count == 5, "5 more events should be queued up")
        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty, "events should have been flushed")
    }

    func testDropEvents() {
        mixpanel.delegate = self
        var events = Queue()
        for i in 0..<5000 {
            events.append(["i": i])
        }
        mixpanel.eventsQueue = events
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.count == 5000)
        for i in 0..<5 {
            mixpanel.track(event: "event", properties: ["i": 5000 + i])
        }
        waitForSerialQueue()
        var e: Properties = mixpanel.eventsQueue.last!
        XCTAssertTrue(mixpanel.eventsQueue.count == 5000)
        XCTAssertEqual(e["properties"]?["i"], 5004)
    }

    func testIdentify() {
        for _ in 0..<2 {
            // run this twice to test reset works correctly wrt to distinct ids
            let distinctId: String = "d1"
            // try this for ODIN and nil
            XCTAssertEqual(mixpanel.distinctId,
                           mixpanel.defaultDistinctId(),
                           "mixpanel identify failed to set default distinct id")
            XCTAssertNil(mixpanel.people.distinctId,
                         "mixpanel people distinct id should default to nil")
            mixpanel.track(event: "e1")
            waitForSerialQueue()
            XCTAssertTrue(mixpanel.eventsQueue.count == 1,
                          "events should be sent right away with default distinct id")
            XCTAssertEqual(mixpanel.eventsQueue.last?["properties"]?["distinct_id"],
                           mixpanel.defaultDistinctId(),
                           "events should use default distinct id if none set")
            mixpanel.people.set(property: "p1", to: "a")
            waitForSerialQueue()
            XCTAssertTrue(mixpanel.people.peopleQueue.isEmpty,
                          "people records should go to unidentified queue before identify:")
            XCTAssertTrue(mixpanel.people.unidentifiedQueue.count == 1,
                          "unidentified people records not queued")
            XCTAssertEqual(mixpanel.people.unidentifiedQueue.last?["$token"] as? String,
                           kTestToken,
                           "incorrect project token in people record")
            mixpanel.identify(distinctId: distinctId)
            waitForSerialQueue()
            XCTAssertEqual(mixpanel.distinctId, distinctId,
                           "mixpanel identify failed to set distinct id")
            XCTAssertEqual(mixpanel.people.distinctId, distinctId,
                           "mixpanel identify failed to set people distinct id")
            XCTAssertTrue(mixpanel.people.unidentifiedQueue.isEmpty,
                          "identify: should move records from unidentified queue")
            XCTAssertTrue(mixpanel.people.peopleQueue.count == 1,
                          "identify: should move records to main people queue")
            XCTAssertEqual(mixpanel.people.peopleQueue.last?["$token"] as? String,
                           kTestToken, "incorrect project token in people record")
            XCTAssertEqual(mixpanel.people.peopleQueue.last?["$distinct_id"] as? String,
                           distinctId, "distinct id not set properly on unidentified people record")
            var p: Properties = mixpanel.people.peopleQueue.last?["$set"] as! Properties
            XCTAssertEqual(p["p1"] as? String, "a", "custom people property not queued")
            assertDefaultPeopleProperties(p)
            mixpanel.people.set(property: "p1", to: "a")
            waitForSerialQueue()
            XCTAssertTrue(mixpanel.people.unidentifiedQueue.isEmpty,
                          "once idenitfy: is called, unidentified queue should be skipped")
            XCTAssertTrue(mixpanel.people.peopleQueue.count == 2,
                          "once identify: is called, records should go straight to main queue")
            mixpanel.track(event: "e2")
            waitForSerialQueue()
            let newDistinctId = mixpanel.eventsQueue.last?["properties"]?["distinct_id"]
            XCTAssertEqual(newDistinctId, distinctId,
                           "events should use new distinct id after identify:")
            mixpanel.reset()
            waitForSerialQueue()
        }
    }
    func testTrackWithDefaultProperties() {
        mixpanel.track(event: "Something Happened")
        waitForSerialQueue()
        var e: Properties = mixpanel.eventsQueue.last!
        XCTAssertEqual(e["event"] as? String, "Something Happened", "incorrect event name")
        var p: Properties = e["properties"] as! Properties
        XCTAssertNotNil(p["$app_build_number"], "$app_build_number not set")
        XCTAssertNotNil(p["$app_version_string"], "$app_version_string not set")
        XCTAssertNotNil(p["$lib_version"], "$lib_version not set")
        XCTAssertNotNil(p["$model"], "$model not set")
        XCTAssertNotNil(p["$os"], "$os not set")
        XCTAssertNotNil(p["$os_version"], "$os_version not set")
        XCTAssertNotNil(p["$screen_height"], "$screen_height not set")
        XCTAssertNotNil(p["$screen_width"], "$screen_width not set")
        XCTAssertNotNil(p["distinct_id"], "distinct_id not set")
        XCTAssertNotNil(p["time"], "time not set")
        XCTAssertEqual(p["$manufacturer"] as? String, "Apple", "incorrect $manufacturer")
        XCTAssertEqual(p["mp_lib"] as? String, "swift", "incorrect mp_lib")
        XCTAssertEqual(p["token"] as? String, kTestToken, "incorrect token")
    }

    func testTrackWithCustomProperties() {
        let now = NSDate()
        let p: Properties = ["string": "yello",
                             "number": 3,
                             "date": now,
                             "$app_version_string": "override"]
        mixpanel.track(event: "Something Happened", properties: p)
        waitForSerialQueue()
        var props: Properties = mixpanel.eventsQueue.last?["properties"] as! Properties
        XCTAssertEqual(props["string"] as? String, "yello")
        XCTAssertEqual(props["number"] as? Int, 3)
        XCTAssertEqual(props["date"] as? NSDate, now)
        XCTAssertEqual(props["$app_version_string"] as? String, "override",
                       "reserved property override failed")
    }

    func testTrackWithCustomDistinctIdAndToken() {
        let p: Properties = ["token": "t1", "distinct_id": "d1"]
        mixpanel.track(event: "e1", properties: p)
        waitForSerialQueue()
        let trackToken = mixpanel.eventsQueue.last?["properties"]?["token"]!
        let trackDistinctId = mixpanel.eventsQueue.last?["properties"]?["distinct_id"]!
        XCTAssertEqual(trackToken, "t1", "user-defined distinct id not used in track.")
        XCTAssertEqual(trackDistinctId, "d1", "user-defined distinct id not used in track.")
    }

    func testRegisterSuperProperties() {
        var p: Properties = ["p1": "a", "p2": 3, "p3": NSDate()]
        mixpanel.registerSuperProperties(p)
        waitForSerialQueue()
        XCTAssertEqual(NSDictionary(dictionary: mixpanel.currentSuperProperties()),
                       NSDictionary(dictionary: p),
                       "register super properties failed")
        p = ["p1": "b"]
        mixpanel.registerSuperProperties(p)
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.currentSuperProperties()["p1"] as? String, "b",
                       "register super properties failed to overwrite existing value")
        p = ["p4": "a"]
        mixpanel.registerSuperPropertiesOnce(p)
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.currentSuperProperties()["p4"] as? String, "a",
                       "register super properties once failed first time")
        p = ["p4": "b"]
        mixpanel.registerSuperPropertiesOnce(p)
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.currentSuperProperties()["p4"] as? String, "a",
                       "register super properties once failed second time")
        p = ["p4": "c"]
        mixpanel.registerSuperPropertiesOnce(p, defaultValue: "d")
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.currentSuperProperties()["p4"] as? String, "a",
                       "register super properties once with default value failed when no match")
        mixpanel.registerSuperPropertiesOnce(p, defaultValue: "a")
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.currentSuperProperties()["p4"] as? String, "c",
                       "register super properties once with default value failed when match")
        mixpanel.unregisterSuperProperty("a")
        waitForSerialQueue()
        XCTAssertNil(mixpanel.currentSuperProperties()["a"],
                     "unregister super property failed")
        // unregister non-existent super property should not throw
        mixpanel.unregisterSuperProperty("a")
        mixpanel.clearSuperProperties()
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.currentSuperProperties().isEmpty,
                      "clear super properties failed")
    }

    func testInvalidPropertiesTrack() {
        let p: Properties = ["data": NSData()]
        XCTExpectAssert("property type should not be allowed") {
            self.mixpanel.track(event: "e1", properties: p)
        }
    }

    func testInvalidSuperProperties() {
        let p: Properties = ["data": NSData()]
        XCTExpectAssert("property type should not be allowed") {
            self.mixpanel.registerSuperProperties(p)
        }
        XCTExpectAssert("property type should not be allowed") {
            self.mixpanel.registerSuperPropertiesOnce(p)
        }
        XCTExpectAssert("property type should not be allowed") {
            self.mixpanel.registerSuperPropertiesOnce(p, defaultValue: "v")
        }
    }

    func testValidPropertiesTrack() {
        let p: Properties = allPropertyTypes()
        mixpanel.track(event: "e1", properties: p)
    }

    func testValidSuperProperties() {
        let p: Properties = allPropertyTypes()
        mixpanel.registerSuperProperties(p)
        mixpanel.registerSuperPropertiesOnce(p)
        mixpanel.registerSuperPropertiesOnce(p, defaultValue: "v")
    }

    func testTrackLaunchOptions() {
        let launchOptions: Properties = [UIApplicationLaunchOptionsRemoteNotificationKey: ["mp":
            ["m": "the_message_id", "c": "the_campaign_id"]]]
        mixpanel = Mixpanel.initialize(token: kTestToken,
                                       launchOptions: launchOptions,
                                       flushInterval: 60)
        waitForSerialQueue()
        var e: Properties = mixpanel.eventsQueue.last!
        XCTAssertEqual(e["event"] as? String, "$app_open", "incorrect event name")
        var p: Properties = e["properties"] as! Properties
        XCTAssertEqual(p["campaign_id"] as? String, "the_campaign_id", "campaign_id not equal")
        XCTAssertEqual(p["message_id"] as? String, "the_message_id", "message_id not equal")
        XCTAssertEqual(p["message_type"] as? String, "push", "type does not equal inapp")
    }

    func testTrackPushNotification() {
        mixpanel.trackPushNotification(["mp": ["m": "the_message_id", "c": "the_campaign_id"]])
        waitForSerialQueue()
        var e: Properties = mixpanel.eventsQueue.last!
        XCTAssertEqual(e["event"] as? String, "$campaign_received", "incorrect event name")
        var p: Properties = e["properties"] as! Properties
        XCTAssertEqual(p["campaign_id"] as? String, "the_campaign_id", "campaign_id not equal")
        XCTAssertEqual(p["message_id"] as? String, "the_message_id", "message_id not equal")
        XCTAssertEqual(p["message_type"] as? String, "push", "type does not equal inapp")
    }

    func testTrackPushNotificationMalformed() {
        mixpanel.trackPushNotification(["mp":
            ["m": "the_message_id", "cid": "the_campaign_id"]])
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "Invalid push notification was incorrectly queued.")
        mixpanel.trackPushNotification(["mp": 1])
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "Invalid push notification was incorrectly queued.")
        mixpanel.trackPushNotification([:])
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "Invalid push notification was incorrectly queued.")
        mixpanel.trackPushNotification(["mp": "bad value"])
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "Invalid push notification was incorrectly queued.")
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "Invalid push notification was incorrectly queued.")
    }

    func testReset() {
        mixpanel.identify(distinctId: "d1")
        mixpanel.track(event: "e1")
        let p: Properties = ["p1": "a"]
        mixpanel.registerSuperProperties(p)
        mixpanel.people.set(properties: p)
        mixpanel.archive()
        mixpanel.reset()
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.distinctId,
                       mixpanel.defaultDistinctId(),
                       "distinct id failed to reset")
        XCTAssertNil(mixpanel.people.distinctId, "people distinct id failed to reset")
        XCTAssertTrue(mixpanel.currentSuperProperties().isEmpty,
                      "super properties failed to reset")
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty, "events queue failed to reset")
        XCTAssertTrue(mixpanel.people.peopleQueue.isEmpty, "people queue failed to reset")
        mixpanel = Mixpanel.initialize(token: kTestToken, launchOptions: nil, flushInterval: 60)
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.distinctId, mixpanel.defaultDistinctId(),
                       "distinct id failed to reset after archive")
        XCTAssertNil(mixpanel.people.distinctId,
                     "people distinct id failed to reset after archive")
        XCTAssertTrue(mixpanel.currentSuperProperties().isEmpty,
                      "super properties failed to reset after archive")
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "events queue failed to reset after archive")
        XCTAssertTrue(mixpanel.people.peopleQueue.isEmpty,
                      "people queue failed to reset after archive")
    }

    func testArchive() {
        mixpanel.archive()
        mixpanel = Mixpanel.initialize(token: kTestToken, launchOptions: nil, flushInterval: 60)
        XCTAssertEqual(mixpanel.distinctId, mixpanel.defaultDistinctId(),
                       "default distinct id archive failed")
        XCTAssertTrue(mixpanel.currentSuperProperties().isEmpty,
                      "default super properties archive failed")
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty, "default events queue archive failed")
        XCTAssertNil(mixpanel.people.distinctId, "default people distinct id archive failed")
        XCTAssertTrue(mixpanel.people.peopleQueue.isEmpty, "default people queue archive failed")
        let p: Properties = ["p1": "a"]
        mixpanel.identify(distinctId: "d1")
        mixpanel.registerSuperProperties(p)
        mixpanel.track(event: "e1")
        mixpanel.people.set(properties: p)
        mixpanel.timedEvents["e2"] = 5.0
        waitForSerialQueue()
        mixpanel.archive()
        mixpanel = Mixpanel.initialize(token: kTestToken, launchOptions: nil, flushInterval: 60)
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.distinctId, "d1", "custom distinct archive failed")
        XCTAssertTrue(mixpanel.currentSuperProperties().count == 1,
                      "custom super properties archive failed")
        XCTAssertEqual(mixpanel.eventsQueue.last?["event"] as? String, "e1",
                       "event was not successfully archived/unarchived")
        XCTAssertEqual(mixpanel.people.distinctId, "d1",
                       "custom people distinct id archive failed")
        XCTAssertTrue(mixpanel.people.peopleQueue.count == 1, "pending people queue archive failed")
        XCTAssertEqual(mixpanel.timedEvents["e2"] as? Double, 5.0,
                       "timedEvents archive failed")
        let fileManager = NSFileManager.defaultManager()
        XCTAssertTrue(fileManager.fileExistsAtPath(
            Persistence.filePathWithType(.Events, token: kTestToken)!),
                      "events archive file not removed")
        XCTAssertTrue(fileManager.fileExistsAtPath(
            Persistence.filePathWithType(.People, token: kTestToken)!),
                      "people archive file not removed")
        XCTAssertTrue(fileManager.fileExistsAtPath(
            Persistence.filePathWithType(.Properties, token: kTestToken)!),
                      "properties archive file not removed")
        mixpanel = Mixpanel.initialize(token: kTestToken, launchOptions: nil, flushInterval: 60)
        XCTAssertEqual(mixpanel.distinctId, "d1", "expecting d1 as distinct id as initialised")
        XCTAssertTrue(mixpanel.currentSuperProperties().count == 1,
                      "default super properties expected to have 1 item")
        XCTAssertNotNil(mixpanel.eventsQueue, "default events queue from no file is nil")
        XCTAssertTrue(mixpanel.eventsQueue.count == 1, "default events queue expecting 1 item")
        XCTAssertNotNil(mixpanel.people.distinctId,
                        "default people distinct id from no file failed")
        XCTAssertNotNil(mixpanel.people.peopleQueue, "default people queue from no file is nil")
        XCTAssertTrue(mixpanel.people.peopleQueue.count == 1, "default people queue expecting 1 item")
        XCTAssertTrue(mixpanel.timedEvents.count == 1, "timedEvents expecting 1 item")

        Persistence.archiveToFile(.Events, object: "garbage", token: kTestToken)
        Persistence.archiveToFile(.People, object: "garbage", token: kTestToken)
        Persistence.archiveToFile(.Properties, object: "garbage", token: kTestToken)

        XCTAssertTrue(fileManager.fileExistsAtPath(
            Persistence.filePathWithType(.Events, token: kTestToken)!),
                      "events archive file not removed")
        XCTAssertTrue(fileManager.fileExistsAtPath(
            Persistence.filePathWithType(.People, token: kTestToken)!),
                      "people archive file not removed")
        XCTAssertTrue(fileManager.fileExistsAtPath(
            Persistence.filePathWithType(.Properties, token: kTestToken)!),
                      "properties archive file not removed")
        mixpanel = Mixpanel.initialize(token: kTestToken, launchOptions: nil, flushInterval: 60)
        waitForSerialQueue()
        XCTAssertEqual(mixpanel.distinctId, mixpanel.defaultDistinctId(),
                       "default distinct id from garbage failed")
        XCTAssertTrue(mixpanel.currentSuperProperties().isEmpty,
                      "default super properties from garbage failed")
        XCTAssertNotNil(mixpanel.eventsQueue, "default events queue from garbage is nil")
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty,
                      "default events queue from garbage not empty")
        XCTAssertNil(mixpanel.people.distinctId,
                     "default people distinct id from garbage failed")
        XCTAssertNotNil(mixpanel.people.peopleQueue,
                        "default people queue from garbage is nil")
        XCTAssertTrue(mixpanel.people.peopleQueue.isEmpty,
                      "default people queue from garbage not empty")
        XCTAssertTrue(mixpanel.timedEvents.isEmpty,
                      "timedEvents is not empty")
    }

    func testMixpanelDelegate() {
        mixpanel.delegate = self
        mixpanel.identify(distinctId: "d1")
        mixpanel.track(event: "e1")
        mixpanel.people.set(property: "p1", to: "a")
        mixpanel.flush()
        waitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.count == 1, "delegate should have stopped flush")
        XCTAssertTrue(mixpanel.people.peopleQueue.count == 1, "delegate should have stopped flush")
    }

    func testEventTiming() {
        mixpanel.track(event: "Something Happened")
        waitForSerialQueue()
        var e: Properties = mixpanel.eventsQueue.last!
        var p = e["properties"] as! Properties
        XCTAssertNil(p["$duration"], "New events should not be timed.")
        mixpanel.time(event: "400 Meters")
        mixpanel.track(event: "500 Meters")
        waitForSerialQueue()
        e = mixpanel.eventsQueue.last!
        p = e["properties"] as! Properties
        XCTAssertNil(p["$duration"], "The exact same event name is required for timing.")
        mixpanel.track(event: "400 Meters")
        waitForSerialQueue()
        e = mixpanel.eventsQueue.last!
        p = e["properties"] as! Properties
        XCTAssertNotNil(p["$duration"], "This event should be timed.")
        mixpanel.track(event: "400 Meters")
        waitForSerialQueue()
        e = mixpanel.eventsQueue.last!
        p = e["properties"] as! Properties
        XCTAssertNil(p["$duration"],
                     "Tracking the same event should require a second call to timeEvent.")
    }

    func testNetworkingWithStress() {
        _ = stubTrack().andReturn(503)
        for _ in 0..<500 {
            mixpanel.track(event: "Track Call")
        }
        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.count == 500, "none supposed to be flushed")
        LSNocilla.sharedInstance().clearStubs()
        _ = stubTrack().andReturn(200)
        mixpanel.flushInstance.flushRequest.networkRequestsAllowedAfterTime = 0
        flushAndWaitForSerialQueue()
        XCTAssertTrue(mixpanel.eventsQueue.isEmpty, "supposed to all be flushed")
    }

    func testTelephonyInfoInitialized() {
        XCTAssertNotNil(AutomaticProperties.telephonyInfo, "telephonyInfo wasn't initialized")
    }

    func testNestedUnsupportedTypes() {
        stubTrack()
        stubEngage()
        let p = ["property": ["p": [NSData()]]]
        mixpanel.track(event: "test", properties: p)
        mixpanel.identify(distinctId: "1234")
        mixpanel.people.set(properties: p)
        flushAndWaitForSerialQueue()
    }

    func testUnexpectedBeahviours() {
        stubEngage()
        mixpanel.identify(distinctId: "1234")
        mixpanel.people.set(properties: ["p1": "string type"])
        flushAndWaitForSerialQueue()

        mixpanel.people.increment(property: "p1", by: 2.3)
        flushAndWaitForSerialQueue()

        mixpanel.people.union(properties: ["p1": ["unioned item"]])
        flushAndWaitForSerialQueue()

        mixpanel.people.append(properties: ["p1": "appended item"])
        flushAndWaitForSerialQueue()
    }
}
