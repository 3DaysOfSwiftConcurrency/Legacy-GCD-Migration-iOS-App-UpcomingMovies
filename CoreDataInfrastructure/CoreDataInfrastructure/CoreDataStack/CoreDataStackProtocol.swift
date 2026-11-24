//
//  CoreDataStackProtocol.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 2/13/21.
//

import CoreData

protocol CoreDataStackProtocol {

    var persistentContainer: NSPersistentContainer { get }

    func openStore() throws

    func setExtensionPersistentStoreDescriptions(_ groupExtensionIds: [String])

}
