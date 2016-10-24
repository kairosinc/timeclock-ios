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
        
        case Memory
        case SQL(storeURL: NSURL)
        case Binary(storeURL: NSURL)
        
        var type: String {
            switch self {
            case .Memory:   return NSInMemoryStoreType
            case .SQL:      return NSSQLiteStoreType
            case .Binary:   return NSBinaryStoreType
            }
        }
        
        var URL: NSURL? {
            switch self {
            case .Memory: return nil
            case .SQL(let URL): return URL
            case .Binary(let URL): return URL
            }
        }
    }
    
    let store: CoreDataStack.Store
    let modelURL: NSURL
    
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    private let managedObjectModel: NSManagedObjectModel
    let managedObjectContext: NSManagedObjectContext
    
    init?(store: CoreDataStack.Store, modelURL: NSURL) {
        self.store = store
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            return nil
        }
        
        managedObjectModel = model
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(store.type, configuration: nil, URL: store.URL, options: CoreDataStack.options)
        } catch _ {
            
            // If we have no store URL, then the persistent store is a memory type and the failure above is out of our hands.
            guard let storeURL = store.URL else {
                return nil
            }
            
            // Try to remove the existing store from disk and re-add a store to the coordinator
            do {
                let fileManager = NSFileManager()
                try fileManager.removeItemAtURL(storeURL)
                try persistentStoreCoordinator.addPersistentStoreWithType(store.type, configuration: nil, URL: store.URL, options: CoreDataStack.options)
            } catch _ {
                return nil
            }
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
}
