//
//  MovieVisitLocalDataSource.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 11/2/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UpcomingMoviesDomain
import UpcomingMoviesData

final class MovieVisitLocalDataSource: MovieVisitLocalDataSourceProtocol {

    private let store: PersistenceStore<CDMovieVisit>

    var didUpdateMovieVisit: (() -> Void)?

    // MARK: - Initializers

    // TODO: - Make the limit configurable
    init(store: PersistenceStore<CDMovieVisit>) {
        self.store = store
        store.observeSavedChanges { [weak self] in self?.didUpdateMovieVisit?() }
    }

    // MARK: - MovieVisitLocalDataSourceProtocol

    func getMovieVisits(completion: @escaping (Result<[MovieVisit], Error>) -> Void) {
        let context = store.createBackgroundContext()
        context.perform {
            completion(Result {
                try self.store.openStore()
                let request = CDMovieVisit.sortedFetchRequest
                request.fetchLimit = 10
                return try context.fetch(request).map { $0.asDomain() }
            })
        }
    }

    func save(with id: Int, title: String, posterPath: String?,
              completion: @escaping (Result<Void, Error>) -> Void) {
        store.saveMovieVisit(with: id, title: title, posterPath: posterPath, completion: completion)
    }

}
