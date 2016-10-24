//
//  CoreDataStackTests.swift
//
//  Created by Tom Hutchinson on 24/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CoreData
import XCTest

@testable import Timeclock

class CoreDataStackTests: XCTestCase {
    
    func testBinaryStoreURL() {
        let URL = NSURL(string: "http://example.com")!
        let store = CoreDataStack.Store.Binary(storeURL: URL)
        XCTAssertEqual(store.URL, URL)
    }
    
    func testBinaryStoreType() {
        let store = CoreDataStack.Store.Binary(storeURL: NSURL())
        XCTAssertEqual(store.type, NSBinaryStoreType)
    }
    
    func testMemoryStoreURL() {
        let store = CoreDataStack.Store.Memory
        XCTAssertNil(store.URL)
    }
    
    func testMemoryStoreType() {
        let store = CoreDataStack.Store.Memory
        XCTAssertEqual(store.type, NSInMemoryStoreType)
    }
    
    func testSQLStoreURL() {
        let URL = NSURL(string: "http://example.com")!
        let store = CoreDataStack.Store.SQL(storeURL: URL)
        XCTAssertEqual(store.URL, URL)
    }
    
    func testSQLStoreType() {
        let store = CoreDataStack.Store.SQL(storeURL: NSURL())
        XCTAssertEqual(store.type, NSSQLiteStoreType)
    }
    
    func testManagedObjectContext() {
        let store = CoreDataStack.Store.Memory
        let stack = CoreDataStack(store: store, modelURL: DataController.modelURL!)
        XCTAssertNotNil(stack?.managedObjectContext)
        XCTAssertEqual(stack?.managedObjectContext.concurrencyType, .MainQueueConcurrencyType)
    }
    
    func testIncorrectModelURL() {
        let store = CoreDataStack.Store.Memory
        let URL = NSURL(string: "http://example.com")!
        let stack = CoreDataStack(store: store, modelURL: URL)
        XCTAssertNil(stack?.managedObjectContext)
    }
    
    func testDifferentModel() {
        let URL = NSURL.fileURLWithPath((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(NSUUID().UUIDString))
        let fileManager = NSFileManager()
        let store = CoreDataStack.Store.SQL(storeURL: URL)
        _ = CoreDataStack(store: store, modelURL: DataController.modelURL!)
        XCTAssertTrue(fileManager.fileExistsAtPath(URL.path!))
        
        let testModelURL = NSBundle(forClass: self.dynamicType).URLForResource("Test", withExtension: "momd")!
        let stack = CoreDataStack(store: store, modelURL: testModelURL)
        XCTAssertTrue(fileManager.fileExistsAtPath(URL.path!))
        let model = stack?.managedObjectContext.persistentStoreCoordinator?.managedObjectModel
        XCTAssertEqual(model?.entities.count, 1)
        XCTAssertEqual(model?.entities.first?.name, "TestEntity")
    }

}
