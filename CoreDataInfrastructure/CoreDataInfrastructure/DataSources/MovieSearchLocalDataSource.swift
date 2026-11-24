//
//  MovieSearchLocalDataSource.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 11/2/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UpcomingMoviesDomain
import UpcomingMoviesData

final class MovieSearchLocalDataSource: MovieSearchLocalDataSourceProtocol {

    private let store: PersistenceStore<CDMovieSearch>

    var didUpdateMovieSearch: (() -> Void)?

    // MARK: - Initializers

    init(store: PersistenceStore<CDMovieSearch>) {
        self.store = store
        store.observeSavedChanges { [weak self] in self?.didUpdateMovieSearch?() }
    }

    // MARK: - MovieSearchLocalDataSourceProtocol

    func getMovieSearches(completion: @escaping (Result<[MovieSearch], Error>) -> Void) {
        let context = store.createBackgroundContext()
        context.perform {
            completion(Result {
                try self.store.openStore()
                let request = CDMovieSearch.sortedFetchRequest
                return try context.fetch(request).map { $0.asDomain() }
            })
        }
    }

    func save(with searchText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        store.saveMovieSearch(with: searchText, completion: completion)
    }

}
