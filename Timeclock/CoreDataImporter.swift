//
//  CoreDataImporter.swift
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CoreData
import Foundation

class CoreDataImporter {
    let mainContext: NSManagedObjectContext
    let importContext: NSManagedObjectContext
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    init(managedObjectContext: NSManagedObjectContext) {
        mainContext = managedObjectContext
        importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = mainContext.persistentStoreCoordinator
        
        
        notificationCenter.addObserver(self, selector: #selector(importContextDidSaveNotification), name: NSManagedObjectContextDidSaveNotification, object: importContext)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: importContext)
    }
    
    @objc func importContextDidSaveNotification(notification: NSNotification) {
        mainContext.mergeChangesFromContextDidSaveNotification(notification)
    }
}
