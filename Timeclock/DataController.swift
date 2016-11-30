//
//  DataController.swift
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CloudKit
import CoreData
import Foundation

typealias DataControllerConfiguration = (modelURL: NSURL, stack: CoreDataStack)
public typealias PersistObjectCompletion = (managedObject: NSManagedObject?, error: ErrorType?) -> Void
public typealias PersistObjectTuple = (managedObject: NSManagedObject?, error: ErrorType?)

public struct DataController {
    
    static let sharedController = DataController()
    
    public enum ContextType: Int {
        case Main = 0, Importer
    }
    
    static let modelURL = NSBundle(forClass: AppDelegate().dynamicType).URLForResource(CoreDataStack.StoreName, withExtension: "momd")

    static func storeURL() -> NSURL? {
        
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else {
            return nil
        }
        
        let cacheURL = NSURL(fileURLWithPath: cachePath)
        
        let kairosURL = cacheURL.URLByAppendingPathComponent("\(CoreDataStack.StoreName).store")
        
        let fileManager = NSFileManager()
        do {
            try fileManager.createDirectoryAtURL(kairosURL!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            do {
                try fileManager.removeItemAtURL(kairosURL!)
                try fileManager.createDirectoryAtURL(kairosURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        
        //TODO: Replace with real sessionID once we have a backend
        return kairosURL!.URLByAppendingPathComponent("testsessionid")
    }
    
    private let stack: CoreDataStack
    private let importer: CoreDataImporter
    init?(configuration: DataControllerConfiguration? = nil) {
        
        if let configuration = configuration {
            stack = configuration.stack
            
        } else if let modelURL = DataController.modelURL, storeURL = DataController.storeURL() {
            stack = CoreDataStack(store: .SQL(storeURL: storeURL), modelURL: modelURL)!
            
        } else {
            return nil
        }
        
        importer = CoreDataImporter(managedObjectContext: stack.managedObjectContext)
    }
    
    private func contextFrom(type: ContextType) -> NSManagedObjectContext {
        let context: NSManagedObjectContext
        switch type {
        case .Main:
            context = stack.managedObjectContext
        case .Importer:
            context = importer.importContext
        }
        
        return context
    }
    
    //MARK: Fetch Objects
    public func managedObjectIDFromURI(uri: NSURL) -> NSManagedObjectID? {
        let managedObjectContext = stack.managedObjectContext
        let managedObjectID = managedObjectContext.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(uri)
        return managedObjectID
    }
    
    public func objectFromMainContext(objectID: NSManagedObjectID, completion: PersistObjectCompletion) {
        let managedObjectContext = stack.managedObjectContext
        managedObjectContext.performBlock { 
            do {
                let object = try managedObjectContext.existingObjectWithID(objectID)
                completion(managedObject: object, error: nil)
            } catch {
                completion(managedObject: nil, error: error)
            }
        }
    }
    
    public func objectFromMainContextSynchronously(objectID: NSManagedObjectID) -> PersistObjectTuple {
        let managedObjectContext = stack.managedObjectContext
        do {
            let object = try? managedObjectContext.existingObjectWithID(objectID)
            return (object, nil)
        }
    }
    
    private func persistObject<A: NSManagedObject where A: ManagedObjectType>(managedObject: A, completion: (error: ErrorType?) -> Void) {
        guard let context = managedObject.managedObjectContext else { return }
        
        context.performBlock { 
            do {
                try context.save()
                completion(error: nil)
            } catch {
                print("Save error: ", error)
                completion(error: error)
            }
        }
    }
    
    private func persistObjectsInContext(context: NSManagedObjectContext) -> ErrorType? {
        do {
            try context.save()
        } catch {
            return (error)
        }
        
        return (nil)
    }
    
    private func persistObjectSynchronously<A: NSManagedObject where A: ManagedObjectType>(managedObject: A) -> ErrorType? {
        guard let context = managedObject.managedObjectContext else { return (nil) }
        do {
            try context.save()
        } catch {
            return (error)
        }
        
        return (nil)
    }
    
    //MARK: Employee
    public func persistEmployees(jsonArray: [JSONType], completion: PersistObjectCompletion) {
        let context = importer.importContext
        
        //Delete existing User records
        let fetchRequest = NSFetchRequest(entityName: Employee.EntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.executeRequest(deleteRequest)
        
        //Create & persist new Employee object
        for employeeDictionary in jsonArray {
            let employee = Employee.fromJSON(employeeDictionary, inContext: context)
        }
        
        persistObjectsInContext(context)
        completion(managedObject: nil, error: nil)
    }
    
    public func fetchEmployee(
        employeeID: String,
        contextType: ContextType = .Main,
        completion: PersistObjectCompletion) {
        
        let context = contextFrom(contextType)
        
        let fetch = NSFetchRequest(entityName: Employee.EntityName)
        fetch.predicate = NSPredicate(format: "badgeNumber == %@", employeeID)
        let results = try? context.executeFetchRequest(fetch)
        if let results = results, let employee = results.first as? Employee {
            completion(managedObject: employee, error: nil)
            return
        } else {
            completion(managedObject: nil, error: nil)
            return
        }
    }

}
