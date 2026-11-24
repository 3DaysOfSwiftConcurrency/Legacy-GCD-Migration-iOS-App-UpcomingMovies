//
//  NSManagedObjectContext+Extensions.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 1/7/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            fatalError("Wrong object type")
        }
        return obj
    }

    @discardableResult
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    func performChanges(completion: ((Result<Void, Error>) -> Void)? = nil, block: @escaping () -> Void) {
        perform {
            block()
            do {
                try self.save()
                completion?(.success(()))
            } catch {
                self.rollback()
                completion?(.failure(error))
            }
        }
    }

    func performChangesAndWait(block: () -> Void) {
        performAndWait {
            block()
            self.saveOrRollback()
        }
    }

}
