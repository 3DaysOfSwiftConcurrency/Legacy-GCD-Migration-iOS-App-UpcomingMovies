//
//  PersistenceStore+MovieSearch.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 3/4/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

extension PersistenceStore where Entity == CDMovieSearch {

    func saveMovieSearch(with searchText: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        do { try openStore() } catch { completion?(.failure(error)); return }
        managedObjectContext.performChanges(completion: completion) {
            _ = CDMovieSearch.insert(into: self.managedObjectContext,
                                     searchText: searchText, createdAt: self.now())
        }
    }

    func findAll() -> [CDMovieSearch] {
        CDMovieSearch.fetch(in: managedObjectContext)
    }

}
