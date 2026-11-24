//
//  AccountFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/11/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation

/// Owns the account tab's current-user capability.
@MainActor
final class AccountFeature {

    private let authHandler: AuthenticationHandlerProtocol

    init(authHandler: AuthenticationHandlerProtocol) {
        self.authHandler = authHandler
    }

    func loadCurrentUser() async throws -> UserProtocol? {
        try await authHandler.loadCurrentUser()
    }

    func currentUser() -> UserProtocol? {
        authHandler.currentUser()
    }

}
