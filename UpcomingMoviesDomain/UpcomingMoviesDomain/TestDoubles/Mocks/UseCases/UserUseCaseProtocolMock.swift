//
//  UserUseCaseProtocolMock.swift
//  UpcomingMoviesDomain
//
//  Created by Alonso on 7/07/23.
//

import Foundation

public final class UserUseCaseProtocolMock: UserUseCaseProtocol {

    public var didUpdateUser: (() -> Void)?

    var findResult: User?
    private(set) var findCallCount = 0
    public func find(with id: Int) -> User? {
        findCallCount += 1
        return findResult
    }

    public var saveResult: Result<Void, Error> = .success(())
    private(set) var saveUserCallCount = 0
    public func saveUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        saveUserCallCount += 1
        completion(saveResult)
    }

}
