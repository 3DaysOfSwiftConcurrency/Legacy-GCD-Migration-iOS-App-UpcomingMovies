//
//  PersistenceStore+MovieVisit.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 3/4/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import CoreData

extension PersistenceStore where Entity == CDMovieVisit {

    func saveMovieVisit(with id: Int, title: String, posterPath: String?, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let posterPath = posterPath else {
            completion?(.failure(CocoaError(.validationMissingMandatoryProperty)))
            return
        }
        do { try openStore() } catch { completion?(.failure(error)); return }
        managedObjectContext.performChanges(completion: completion) {
            _ = CDMovieVisit.insert(into: self.managedObjectContext,
                                    id: id,
                                    title: title,
                                    posterPath: posterPath, createdAt: self.now())
        }
    }

    func exists() -> Bool {
        countAll() > 0
    }

    func findAll(limit: Int? = nil, completion: (([CDMovieVisit]) -> Void)? = nil) {
        let context = createBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.perform {
            let movieVisits = CDMovieVisit.fetch(in: context, fetchLimit: limit)
            completion?(movieVisits)
        }
    }

    func countAll() -> Int {
        CDMovieVisit.count(in: managedObjectContext)
    }

}
