//
//  PersistenceStore+User.swift
//  CoreDataInfrastructure
//
//  Created by Alonso on 3/31/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

extension PersistenceStore where Entity == CDUser {

    func find(with id: Int) -> CDUser? {
        guard (try? openStore()) != nil else { return nil }
        let predicate = NSPredicate(format: "id == %d", id)
        return CDUser.findOrFetch(in: managedObjectContext, matching: predicate)
    }

    func saveUser(_ user: User, completion: ((Result<Void, Error>) -> Void)? = nil) {
        do { try openStore() } catch { completion?(.failure(error)); return }
        managedObjectContext.performChanges(completion: completion) {
            _ = CDUser.insert(into: self.managedObjectContext,
                              id: user.id,
                              name: user.name,
                              username: user.username,
                              includeAdult: user.includeAdult,
                              avatarPath: user.avatarPath)
        }
    }

}
