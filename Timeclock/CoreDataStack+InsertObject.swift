//
//  CoreDataStack+InsertObject.swift
//
//  Created by Tom Hutchinson on 22/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    
    func insertObject<A: NSManagedObject where A: ManagedObjectType>() -> A {
        guard let obj = NSEntityDescription
            .insertNewObject(forEntityName: A.EntityName,
                                             into: self) as? A else {
                                                fatalError("Entity \(A.EntityName) does not correspond to \(A.self)")
        }
        return obj
    }
}
