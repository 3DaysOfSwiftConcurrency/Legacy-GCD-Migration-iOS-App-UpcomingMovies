//
//  GenreLocalDataSource.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 11/2/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import CoreData
import UpcomingMoviesDomain
import UpcomingMoviesData

final class GenreLocalDataSource: GenreLocalDataSourceProtocol {

    private let store: PersistenceStore<CDGenre>

    private let snapshotContext: NSManagedObjectContext

    var didUpdateGenre: (() -> Void)?

    // MARK: - Initializers

    init(store: PersistenceStore<CDGenre>) {
        self.store = store
        snapshotContext = store.createBackgroundContext()
    }

    // MARK: - GenreLocalDataSourceProtocol

    func saveGenres(_ genres: [Genre]) {
        let context = snapshotContext
        context.perform {
            do {
                try self.store.openStore()
                for row in try context.fetch(CDGenre.sortedFetchRequest) { context.delete(row) }
                for genre in genres { _ = CDGenre.insert(into: context, id: genre.id, name: genre.name) }
                try context.save()
                Task { @MainActor in self.didUpdateGenre?() }
            } catch {
                context.rollback()
            }
        }
    }

    func find(with id: Int) -> Genre? {
        guard (try? store.openStore()) != nil else { return nil }
        return store.find(with: id)?.asDomain()
    }

    func restoreGenres(completion: @escaping ([Genre]) -> Void) {
        let context = snapshotContext
        context.perform {
            guard (try? self.store.openStore()) != nil else { completion([]); return }
            completion(CDGenre.fetch(in: context).map { $0.asDomain() })
        }
    }
}
