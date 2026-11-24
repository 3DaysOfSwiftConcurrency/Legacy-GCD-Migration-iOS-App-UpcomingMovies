//
//  FavoriteStore.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 3/4/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import CoreData

class PersistenceStore<Entity: NSManagedObject> {

    private let persistentContainer: NSPersistentContainer

    private var saveObserver: NSObjectProtocol?

    var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func createBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    // MARK: - Initializers

    let now: () -> Date
    let openStore: () throws -> Void

    init(_ persistentContainer: NSPersistentContainer, now: @escaping () -> Date = Date.init,
         openStore: @escaping () throws -> Void = {}) {
        self.now = now
        self.openStore = openStore
        self.persistentContainer = persistentContainer
    }

    deinit {
        if let saveObserver { NotificationCenter.default.removeObserver(saveObserver) }
    }

    // Consumers reload their own sorted, limited query. Observe committed changes
    // without fetching rows just to establish an app-wide listener at startup.
    func observeSavedChanges(insertionsOnly: Bool = false, onChange: @escaping () -> Void) {
        if let saveObserver { NotificationCenter.default.removeObserver(saveObserver) }
        let keys = insertionsOnly ? [NSInsertedObjectsKey] : [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey]
        saveObserver = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave,
                                                              object: managedObjectContext, queue: nil) { notification in
            let changed = keys.contains { key in
                let rows = notification.userInfo?[key] as? Set<NSManagedObject>
                return rows?.contains(where: { $0 is Entity }) == true
            }
            if changed { onChange() }
        }
    }
}
