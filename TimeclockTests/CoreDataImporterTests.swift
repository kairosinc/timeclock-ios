//
//  CoreDataImporterTests.swift
//
//  Created by Tom Hutchinson on 24/08/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CoreData
import XCTest

@testable import Timeclock

class CoreDataImporterTests: XCTestCase {
    
    func testImport() {
        
        let testBool = true
        let testString = "abcABC123"
        
        let store = CoreDataStack.Store.Memory
        let modelURL = TimeclockTests.modelURL
        let stack = CoreDataStack(store: store, modelURL: modelURL)!
        let mainContext = stack.managedObjectContext
        let importer = CoreDataImporter(managedObjectContext: stack.managedObjectContext)
        let importContext = importer.importContext
        
        let expectation = self.expectation(withDescription: "Importer")
        
        importContext.performBlock {
            
            let testObject = NSEntityDescription.insertNewObjectForEntityForName(TestEntity.EntityName, inManagedObjectContext: importContext) as! TestEntity
            testObject.testBoolAttribute = testBool
            testObject.testStringAttribute = testString
            
            do {
                try importContext.save()
            } catch {
                XCTFail("Save failed. \(error)")
            }
            
            let fetchRequest = NSFetchRequest(entityName: TestEntity.EntityName)
            mainContext.performBlock {
                
                defer {
                    expectation.fulfill()
                }
                
                guard let objects = try? mainContext.executeFetchRequest(fetchRequest) else {
                    XCTFail("Fetch failed.")
                    return
                }
                
                XCTAssertEqual(objects.count, 1)
                
                guard let fetchedTestEntity = objects.first as? TestEntity else {
                    XCTFail("Did not get the fetched TestEntity.")
                    return
                }
                
                XCTAssertEqual(fetchedTestEntity.testBoolAttribute!, testBool)
                XCTAssertEqual(fetchedTestEntity.testStringAttribute!, testString)
            }
        }
        
        waitForExpectations(withTimeout: 30, handler: nil)
    }
}

