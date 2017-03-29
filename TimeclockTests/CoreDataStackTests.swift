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
        let URL = Foundation.URL(string: "http://example.com")!
        let store = CoreDataStack.Store.Binary(storeURL: URL)
        XCTAssertEqual(store.URL, URL)
    }
    
    func testBinaryStoreType() {
        let store = CoreDataStack.Store.Binary(storeURL: URL())
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
        let URL = Foundation.URL(string: "http://example.com")!
        let store = CoreDataStack.Store.SQL(storeURL: URL)
        XCTAssertEqual(store.URL, URL)
    }
    
    func testSQLStoreType() {
        let store = CoreDataStack.Store.SQL(storeURL: URL())
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
        let URL = Foundation.URL(string: "http://example.com")!
        let stack = CoreDataStack(store: store, modelURL: URL)
        XCTAssertNil(stack?.managedObjectContext)
    }
    
    func testDifferentModel() {
        let URL = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString))
        let fileManager = FileManager()
        let store = CoreDataStack.Store.SQL(storeURL: URL)
        _ = CoreDataStack(store: store, modelURL: DataController.modelURL!)
        XCTAssertTrue(fileManager.fileExists(atPath: URL.path!))
        
        let testModelURL = Bundle(for: self.dynamicType).url(forResource: "Test", withExtension: "momd")!
        let stack = CoreDataStack(store: store, modelURL: testModelURL)
        XCTAssertTrue(fileManager.fileExists(atPath: URL.path!))
        let model = stack?.managedObjectContext.persistentStoreCoordinator?.managedObjectModel
        XCTAssertEqual(model?.entities.count, 1)
        XCTAssertEqual(model?.entities.first?.name, "TestEntity")
    }

}
