//
//  DataController.swift
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CloudKit
import CoreData
import Foundation

typealias DataControllerConfiguration = (modelURL: URL, stack: CoreDataStack)
public typealias PersistObjectCompletion = (_ managedObject: NSManagedObject?, _ error: Error?) -> Void
public typealias PersistObjectTuple = (managedObject: NSManagedObject?, error: Error?)

public struct DataController {
    
    static let sharedController = DataController()
    
    let syncScheduler = SyncScheduler()
    
    public enum ContextType: Int {
        case main = 0, importer
    }
    
    static let modelURL = Bundle(for: type(of: AppDelegate())).url(forResource: CoreDataStack.StoreName, withExtension: "momd")

    static func storeURL() -> URL? {
        
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return nil
        }
        
        let cacheURL = URL(fileURLWithPath: cachePath)
        
        let kairosURL = cacheURL.appendingPathComponent("\(CoreDataStack.StoreName).store")
        
        let fileManager = FileManager()
        do {
            try fileManager.createDirectory(at: kairosURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            do {
                try fileManager.removeItem(at: kairosURL)
                try fileManager.createDirectory(at: kairosURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        
        //TODO: Replace with real sessionID once we have a backend
        return kairosURL.appendingPathComponent("testsessionid")
    }
    
    fileprivate let stack: CoreDataStack
    fileprivate let importer: CoreDataImporter
    init?(configuration: DataControllerConfiguration? = nil) {
        
        if let configuration = configuration {
            stack = configuration.stack
            
        } else if let modelURL = DataController.modelURL, let storeURL = DataController.storeURL() {
            stack = CoreDataStack(store: .sql(storeURL: storeURL), modelURL: modelURL)!
            
        } else {
            return nil
        }
        
        importer = CoreDataImporter(managedObjectContext: stack.managedObjectContext)
    }
    
    fileprivate func contextFrom(_ type: ContextType) -> NSManagedObjectContext {
        let context: NSManagedObjectContext
        switch type {
        case .main:
            context = stack.managedObjectContext
        case .importer:
            context = importer.importContext
        }
        
        return context
    }
    
    //MARK: Fetch Objects
    public func managedObjectIDFromURI(_ uri: URL) -> NSManagedObjectID? {
        let managedObjectContext = stack.managedObjectContext
        let managedObjectID = managedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri)
        return managedObjectID
    }
    
    public func objectFromMainContext(_ objectID: NSManagedObjectID, completion: @escaping PersistObjectCompletion) {
        let managedObjectContext = stack.managedObjectContext
        managedObjectContext.perform { 
            do {
                let object = try managedObjectContext.existingObject(with: objectID)
                completion(object, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    public func objectFromMainContextSynchronously(_ objectID: NSManagedObjectID) -> PersistObjectTuple {
        let managedObjectContext = stack.managedObjectContext
        do {
            let object = try? managedObjectContext.existingObject(with: objectID)
            return (object, nil)
        }
    }
    
    fileprivate func persistObject<A: NSManagedObject>(_ managedObject: A, completion: @escaping (_ error: Error?) -> Void) where A: ManagedObjectType {
        guard let context = managedObject.managedObjectContext else { return }
        
        context.perform { 
            do {
                try context.save()
                completion(nil)
            } catch {
                print("Save error: ", error)
                completion(error)
            }
        }
    }
    
    fileprivate func persistObjectsInContext(_ context: NSManagedObjectContext) -> Error? {
        do {
            try context.save()
        } catch {
            return (error)
        }
        
        return (nil)
    }
    
    fileprivate func persistObjectSynchronously<A: NSManagedObject where A: ManagedObjectType>(_ managedObject: A) -> Error? {
        guard let context = managedObject.managedObjectContext else { return (nil) }
        do {
            try context.save()
        } catch {
            return (error)
        }
        
        return (nil)
    }
    
    //MARK: Employee
    public func persistEmployees(_ jsonArray: [JSONType], completion: PersistObjectCompletion) {
        let context = importer.importContext
        
        //Delete existing User records
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Employee.EntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        
        //Create & persist new Employee object
        for employeeDictionary in jsonArray {
            _ = Employee.fromJSON(employeeDictionary, inContext: context)
        }
        
        _ = persistObjectsInContext(context)
        completion(nil, nil)
    }
    
    public func fetchEmployee(
        _ employeeID: String,
        contextType: ContextType = .main,
        completion: PersistObjectCompletion) {
        
        let context = contextFrom(contextType)
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Employee.EntityName)
        fetch.predicate = NSPredicate(format: "badgeNumber == %@", employeeID)
        let results = try? context.fetch(fetch)
        if let results = results, let employee = results.first as? Employee {
            completion(employee, nil)
            return
        } else {
            completion(nil, nil)
            return
        }
    }
    
    public func createAndPersistPunch(
        _ timestampUTC: String,
        timestampLocal: String,
        clockOffset: Int16,
        timezoneOffset: Int16,
        timezoneName: String,
        timezoneDST: Int16,
        badgeNumber: String,
        badgeNumberValid: Bool,
        direction: String,
        online: String,
        facerecTransactionID: String? = nil,
        facerecImageType: String? = nil,
        facerecImageData: String? = nil,
        subjectID: String? = nil,
        confidence: NSNumber? = nil
        ) {
        
        let context = contextFrom(.main)
        let punch = Punch.insertNewInContext(context)!
        
        punch.timestampUTC = timestampUTC
        punch.timestampLocal = timestampLocal
        punch.clockOffset = clockOffset
        punch.timezoneOffset = timezoneOffset
        punch.timezoneName = timezoneName
        punch.timezoneDST = timezoneDST
        punch.badgeNumber = badgeNumber
        punch.badgeNumberValid = badgeNumberValid
        punch.direction = direction
        punch.online = online
        punch.facerecTransactionID = facerecTransactionID
        punch.facerecImageType = facerecImageType
        punch.facerecImageData = facerecImageData
        punch.subjectID = subjectID
        punch.confidence = confidence
        
        persistObjectsInContext(context)
        
        DataController.sharedController?.syncScheduler.seriallyUploadPunches()
        
    }
    
    public func fetchPunches(
        _ limit: Int = 99,
        contextType: ContextType = .main,
        completion: (_ punches: [Punch]?, _ error: Error?) -> Void) {
        
        let context = contextFrom(contextType)
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Punch.EntityName)
        fetch.fetchLimit = limit
        let results = try? context.fetch(fetch)
        if let results = results as? [Punch] {
            completion(results, nil)
            return
        } else {
            completion(nil, nil)
            return
        }
    }
    
    public func deletePunches(
        _ punches: [Punch],
        contextType: ContextType = .main,
        completion: (_ error: Error?) -> Void) {
        
        let context = contextFrom(contextType)
        
        for punch in punches {
            context.delete(punch)
        }
        
        let error = self.persistObjectsInContext(context)
        
        completion(error)
    }
}
