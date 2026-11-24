//
//  UserUseCaseProtocol.swift
//  UpcomingMoviesDomain
//
//  Created by Alonso on 10/27/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

public protocol UserUseCaseProtocol {

    var didUpdateUser: (() -> Void)? { get set }

    func loadUser(with id: Int, completion: @escaping (Result<User?, Error>) -> Void)
    func find(with id: Int) -> User?
    func saveUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void)

}

public extension UserUseCaseProtocol {
    func loadUser(with id: Int, completion: @escaping (Result<User?, Error>) -> Void) {
        completion(.success(find(with: id)))
    }
}
