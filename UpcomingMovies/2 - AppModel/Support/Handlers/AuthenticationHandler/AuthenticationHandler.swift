//
//  AuthenticationManager.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/24/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

final class AuthenticationHandler: AuthenticationHandlerProtocol {

    private let authUseCase: AuthUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol

    // MARK: - Initializers

    init(authUseCase: AuthUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
    }

    // MARK: - Authentitation Persistence

    func loadCurrentUser() async throws -> UserProtocol? {
        guard let id = authUseCase.currentUserId() else { return nil }
        let user = try await withCheckedThrowingContinuation { continuation in
            userUseCase.loadUser(with: id) { continuation.resume(with: $0) }
        }
        return user.map(UserModel.init)
    }

    func currentUser() -> UserProtocol? {
        guard let userId = authUseCase.currentUserId() else { return nil }
        return userUseCase.find(with: userId).flatMap(UserModel.init)
    }

    func isUserSignedIn() -> Bool {
        currentUser() != nil
    }

    func deleteCurrentUser() {
        authUseCase.signOutUser(completion: { _ in })
    }

}
