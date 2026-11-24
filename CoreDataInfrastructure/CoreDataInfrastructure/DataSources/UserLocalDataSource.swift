//
//  UserLocalDataSource.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 11/2/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UpcomingMoviesDomain
import UpcomingMoviesData

final class UserLocalDataSource: UserLocalDataSourceProtocol {

    private let store: PersistenceStore<CDUser>

    var didUpdateUser: (() -> Void)?

    // MARK: - Initializers

    init(store: PersistenceStore<CDUser>) {
        self.store = store
        store.observeSavedChanges(insertionsOnly: true) { [weak self] in self?.didUpdateUser?() }
    }

    // MARK: - UserLocalDataSourceProtocol

    func loadUser(with id: Int, completion: @escaping (Result<User?, Error>) -> Void) {
        let context = store.createBackgroundContext()
        context.perform {
            completion(Result {
                try self.store.openStore()
                let request = CDUser.sortedFetchRequest
                request.predicate = NSPredicate(format: "id == %d", id)
                request.fetchLimit = 1
                return try context.fetch(request).first?.asDomain()
            })
        }
    }

    func find(with id: Int) -> User? {
        store.find(with: id)?.asDomain()
    }

    func saveUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        self.store.saveUser(user, completion: completion)
    }

}
