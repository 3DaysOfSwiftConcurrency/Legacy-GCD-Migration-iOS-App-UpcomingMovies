//
//  AuthenticationHandlerProtocol.swift
//  UpcomingMovies
//
//  Created by Alonso on 15/03/21.
//  Copyright © 2021 Alonso. All rights reserved.
//

protocol AuthenticationHandlerProtocol {

    func loadCurrentUser() async throws -> UserProtocol?
    func currentUser() -> UserProtocol?
    func isUserSignedIn() -> Bool
    func deleteCurrentUser()

}

extension AuthenticationHandlerProtocol {
    func loadCurrentUser() async throws -> UserProtocol? { currentUser() }
}
