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
    fileprivate let notificationCenter = NotificationCenter.default
    
    init(managedObjectContext: NSManagedObjectContext) {
        mainContext = managedObjectContext
        importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = mainContext.persistentStoreCoordinator
        
        
        notificationCenter.addObserver(self, selector: #selector(importContextDidSaveNotification), name: NSNotification.Name.NSManagedObjectContextDidSave, object: importContext)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: importContext)
    }
    
    @objc func importContextDidSaveNotification(_ notification: Notification) {
        mainContext.mergeChanges(fromContextDidSave: notification)
    }
}
