//
//  CoreDataStack.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 10/26/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import CoreData

public class CoreDataStack: CoreDataStackProtocol {

    public static let shared = CoreDataStack()

    private var groupExtensionIds: [String] = []

    init() {}

    init(container: NSPersistentContainer) {
        persistentContainer = container
    }

    // MARK: - CoreDataStackProtocol

    func setExtensionPersistentStoreDescriptions(_ groupExtensionIds: [String]) {
        self.groupExtensionIds = groupExtensionIds
    }

    // MARK: - Private

    // The bundled schema can be read off the main actor without touching the user's database.
    private static let managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: CoreDataStack.self)
        guard let url = bundle.url(forResource: Constants.containerName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            preconditionFailure("The app bundle is missing the movie data model.")
        }
        return model
    }()

    public static func prepareManagedObjectModel() {
        _ = managedObjectModel
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.containerName, managedObjectModel: Self.managedObjectModel)
        container.viewContext.mergePolicy = NSMergePolicy.overwrite
        return container
    }()

    private let openLock = NSLock()
    private var opened = false

    func openStore() throws {
        openLock.lock()
        defer { openLock.unlock() }
        guard !opened else { return }
        let container = persistentContainer
        if !groupExtensionIds.isEmpty {
            container.persistentStoreDescriptions = try groupExtensionIds.map { group in
                NSPersistentStoreDescription(url: try URL.storeURL(for: group, databaseName: Constants.containerName))
            }
        }
        for description in container.persistentStoreDescriptions {
            if let url = description.url, url.isFileURL {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            }
            description.shouldAddStoreAsynchronously = false
        }
        var failure: Error?
        container.loadPersistentStores { _, error in
            if let error { failure = error }
        }
        if let failure { throw failure }
        opened = true
    }

    // MARK: - Test mockups

    lazy var mockPersistantContainer: NSPersistentContainer = {
        let bundle = Bundle(for: CoreDataStack.self)
        guard let url = bundle.url(forResource: Constants.containerName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError()
        }

        let container = NSPersistentContainer(name: Constants.containerName, managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in

            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )

            // Check if creating container wrong
            if let error = error {
                fatalError("In memory coordinator creation failed \(error)")
            }
        }
        return container
    }()

    private func isTesting() -> Bool {
        NSClassFromString("XCTest") != nil
    }

}

// MARK: - Constants

extension CoreDataStack {

    struct Constants {
        static let containerName = "Model"
    }

}
