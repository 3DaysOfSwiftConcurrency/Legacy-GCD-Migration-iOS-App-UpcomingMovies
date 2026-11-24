//
//  CDMovieSearchStoreTests.swift
//  CoreDataInfrastructureTests
//
//  Created by Alonso on 11/30/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import CoreData
import XCTest

@testable import CoreDataInfrastructure
@testable import UpcomingMoviesDomain

class CDMovieSearchStoreTests: XCTestCase {

    private var storeToTest: PersistenceStore<CDMovieSearch>!

    override func setUp() {
        super.setUp()
        storeToTest = PersistenceStore(CoreDataStack.shared.mockPersistantContainer)
    }

    override func tearDown() {
        storeToTest = nil
        super.tearDown()
    }

    func testFileStoreRetriesDirectoryFailureAndReusesOpenedStore() throws {
        let manager = FileManager.default
        let directory = manager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: directory) }
        let parent = directory.appendingPathComponent("database")
        try Data().write(to: parent)
        let url = parent.appendingPathComponent("Model.sqlite")
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "Record"
        entity.managedObjectClassName = "NSManagedObject"
        model.entities = [entity]
        let container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        let stack = CoreDataStack(container: container)
        XCTAssertTrue(container.persistentStoreCoordinator.persistentStores.isEmpty)
        XCTAssertThrowsError(try stack.openStore())
        try manager.removeItem(at: parent)
        try stack.openStore()
        let coordinator = container.persistentStoreCoordinator
        let opened = try XCTUnwrap(coordinator.persistentStores.first)
        XCTAssertEqual(opened.url, url)
        let context = container.viewContext
        NSEntityDescription.insertNewObject(forEntityName: "Record", into: context)
        try context.save()
        let request = NSFetchRequest<NSManagedObject>(entityName: "Record")
        try stack.openStore()
        XCTAssertTrue(coordinator.persistentStores.first === opened)
        XCTAssertEqual(try context.fetch(request).count, 1)
    }

    @MainActor
    func testHistoryUsesTimeOfEachSaveForMostRecentFirstOrdering() async throws {
        let container = CoreDataStack.shared.mockPersistantContainer
        var instant = Date(timeIntervalSince1970: 86_399)
        let store = PersistenceStore<CDMovieSearch>(container, now: { instant })
        let prefix = UUID().uuidString
        for offset in 0..<2 {
            let outcome: Result<Void, Error> = await withCheckedContinuation { continuation in
                store.saveMovieSearch(with: prefix + String(offset)) { continuation.resume(returning: $0) }
            }
            try outcome.get()
            instant.addTimeInterval(1)
        }
        let rows = store.findAll().filter { $0.searchText.hasPrefix(prefix) }
        defer {
            rows.forEach(container.viewContext.delete)
            try? container.viewContext.save()
        }
        XCTAssertEqual(rows.map(\.searchText), [prefix + "1", prefix + "0"])
        XCTAssertEqual(rows.map { $0.createdAt.timeIntervalSince1970 }, [86_400, 86_399])
    }

    func testSaveMovieSearch() {
        // Arrange
        let saveExpectation = XCTestExpectation(description: "Save movie search")
        // Act
        storeToTest.saveMovieSearch(with: "Search") { [weak self] _ in
            guard let self = self else { return }
            let savedMovieSearch = CDMovieSearch.fetch(in: self.storeToTest.managedObjectContext).first
            XCTAssertNotNil(savedMovieSearch)
            saveExpectation.fulfill()
        }
        // Assert
        wait(for: [saveExpectation], timeout: 1.0)
    }

}
