//
//  UserLocalDataSourceProtocol.swift
//  UpcomingMoviesData
//
//  Created by Alonso on 11/2/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

public protocol UserLocalDataSourceProtocol: AnyObject {

    var didUpdateUser: (() -> Void)? { get set }

    func loadUser(with id: Int, completion: @escaping (Result<User?, Error>) -> Void)
    func find(with id: Int) -> User?
    func saveUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void)

}

public extension UserLocalDataSourceProtocol {
    func loadUser(with id: Int, completion: @escaping (Result<User?, Error>) -> Void) {
        completion(.success(find(with: id)))
    }
}
