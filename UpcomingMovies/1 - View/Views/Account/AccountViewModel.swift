//
//  AccountViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/20/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

final class AccountViewModel: AccountViewModelProtocol {

    private let accountFeature: AccountFeature

    let showAuthPermission = PublishBindable<URL>().eraseToAnyBindable()
    let didReceiveError = PublishBindable<Void>().eraseToAnyBindable()

    var title: String? { LocalizedStrings.accountTabBarTitle() }

    var navigationItemTitle: String? { LocalizedStrings.accountTitle() }

    // MARK: - Initializers

    init(accountFeature: AccountFeature) {
        self.accountFeature = accountFeature
    }

    // MARK: - AccountViewModelProtocol

    func isUserSignedIn() -> Bool {
        currentUser() != nil
    }

    func loadCurrentUser() async throws -> UserProtocol? {
        try await accountFeature.loadCurrentUser()
    }

    func currentUser() -> UserProtocol? {
        accountFeature.currentUser()
    }

}
