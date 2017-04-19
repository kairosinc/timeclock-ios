//
//  CoreDataStack.swift
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CoreData
import Foundation
import UIKit

struct CoreDataStack {
    
    static let StoreName = "Model"
    static let options = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    enum Store {
        
        case memory
        case sql(storeURL: Foundation.URL)
        case binary(storeURL: Foundation.URL)
        
        var type: String {
            switch self {
            case .memory:   return NSInMemoryStoreType
            case .sql:      return NSSQLiteStoreType
            case .binary:   return NSBinaryStoreType
            }
        }
        
        var URL: Foundation.URL? {
            switch self {
            case .memory: return nil
            case .sql(let URL): return URL
            case .binary(let URL): return URL
            }
        }
    }
    
    let store: CoreDataStack.Store
    let modelURL: URL
    
    fileprivate let persistentStoreCoordinator: NSPersistentStoreCoordinator
    fileprivate let managedObjectModel: NSManagedObjectModel
    let managedObjectContext: NSManagedObjectContext
    
    init?(store: CoreDataStack.Store, modelURL: URL) {
        self.store = store
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        
        managedObjectModel = model
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: store.type, configurationName: nil, at: store.URL, options: CoreDataStack.options)
        } catch _ {
            
            // If we have no store URL, then the persistent store is a memory type and the failure above is out of our hands.
            guard let storeURL = store.URL else {
                return nil
            }
            
            // Try to remove the existing store from disk and re-add a store to the coordinator
            do {
                let fileManager = FileManager()
                try fileManager.removeItem(at: storeURL)
                try persistentStoreCoordinator.addPersistentStore(ofType: store.type, configurationName: nil, at: store.URL, options: CoreDataStack.options)
            } catch _ {
                return nil
            }
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
}
